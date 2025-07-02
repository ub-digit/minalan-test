defmodule MyloansApi.Resource.Patron.Remap.Issues do
  import MyloansApi.Resource.Common

  def remap({:error, error}), do: {:error, error}
  def remap({:ok, %{"issues" => _} = map}, key) do
    remapped =
      map[key]
      |> Enum.map(fn issue -> apply_borrower_restrictions(issue, map["borrower"]) end)
      |> Enum.map(&remap_issue/1)
      |> Enum.sort_by(fn item -> item["date_due"] end)

    {:ok, Map.put(map, key, remapped)}
  end
  def remap({:ok, map}, _), do: {:ok, map}

  def apply_borrower_restrictions(issue, %{"can_renew" => %{"allowed" => false, "reason" => "FINES_EXCEEDED"}}) do
    Map.put(issue, "too_much_oweing", 1)
  end
  def apply_borrower_restrictions(issue, %{"can_renew" => %{"allowed" => false, "reason" => "CARD_EXPIRED"}}) do
    Map.put(issue, "card_expired", 1)
  end
  def apply_borrower_restrictions(issue, _), do: issue

  def remap_issue(%{"itemtype_data" => %{"description" => description}} = map) do
    map
    |> Map.put("itemtype_description", description)
    |> Map.delete("itemtype_data")
    |> remap_issue()
  end
  def remap_issue(map) do
    map
    |> truncate_soonestrenewdate()
    |> can_be_renewed()
    |> Enum.filter(fn {key, _} -> Enum.member?(issue_fields(), key) end)
    |> Map.new()
    |> recently_renewed()
    |> add_full_title()
    |> remap_issue_note()
    |> remap_date("date_due")
  end

  defp add_full_title(map) do
    full_title =
      [map["title"], map["subtitle"]]
      |> Enum.reject(&is_blank/1)
      |> Enum.join(" ")
    Map.put(map, "full_title", full_title)
  end

  defp remap_date(map, date_key) do
    date_value =
      map[date_key]
      |> case do
        nil -> ""
        value -> value |> String.split(" ") |> List.first()
      end

    Map.put(map, date_key, date_value)
  end

  defp issue_fields() do
    [
      "biblionumber", "itemnumber", "title", "subtitle", "author",
      "barcode", "date_due", "note", "itype", "issuedate", "returndate",
      "auto_renew", "auto_renew_error", "lastreneweddate", "renewals",
      "renewsleft", "renewsallowed", "charges", "onsite_checkout",
      "itemtype_description", "overdue", "can_be_renewed", "renew_status"
    ]
  end

  defp recently_renewed(%{"lastreneweddate" => lastdate} = map) when is_nil(lastdate),
    do: Map.put(map, "recently_renewed", false)
  defp recently_renewed(%{"lastreneweddate" => ""} = map),
    do: Map.put(map, "recently_renewed", false)
  defp recently_renewed(%{"lastreneweddate" => lastdate} = map) do
    lastdate = NaiveDateTime.from_iso8601!(lastdate)
    now = NaiveDateTime.local_now()
    # Newer than two days is considered recently
    if NaiveDateTime.diff(now, lastdate) < 86400*2 do
      Map.put(map, "recently_renewed", true)
    else
      Map.put(map, "recently_renewed", false)
    end
  end
  defp recently_renewed(map), do: Map.put(map, "recently_renewed", false)

  defp can_be_renewed(%{"too_soon" => 1} = map),
    do: add_renew_error(map, "too_soon", %{"timestamp" => map["soonestrenewdate"]})
  defp can_be_renewed(%{"item_denied_renewal" => 1, "itemlost" => lost} = map) when not(is_nil(lost)) and lost != "0",
    do: add_renew_error(map, "item_lost")
  defp can_be_renewed(%{"on_reserve" => 1} = map), do: add_renew_error(map, "on_reserve")
  defp can_be_renewed(%{"auto_renew" => 0, "renewsallowed" => "0", "renewsleft" => 0} = map), do: add_renew_error(map, "no_renewals_available")
  defp can_be_renewed(%{"auto_renew" => 0, "renewsleft" => 0} = map), do: add_renew_error(map, "no_renewals_left")
  defp can_be_renewed(%{"norenew_overdue" => 1} = map), do: add_renew_error(map, "norenew_overdue")
  defp can_be_renewed(%{"auto_renew" => 1} = map), do: add_renew_error(map, "auto_renew")
  defp can_be_renewed(%{"auto_too_soon" => 1} = map), do: add_renew_error(map, "auto_too_soon")
  defp can_be_renewed(%{"auto_too_late" => 1} = map), do: add_renew_error(map, "auto_too_late")
  defp can_be_renewed(%{"auto_too_much_oweing" => 1} = map), do: add_renew_error(map, "auto_too_much_oweing")
  defp can_be_renewed(%{"too_much_oweing" => 1} = map), do: add_renew_error(map, "too_much_oweing")
  defp can_be_renewed(%{"card_expired" => 1} = map), do: add_renew_error(map, "account_expired")
  defp can_be_renewed(map), do: Map.put(map, "can_be_renewed", true)

  defp add_renew_error(map, reason, extra \\ %{}) do
    status = extra |> Map.put("reason", reason)
    Map.put(map, "can_be_renewed", false)
    |> Map.put("renew_status", status)
  end

  defp truncate_soonestrenewdate(%{"soonestrenewdate" => soonest} = map) do
    # soonestrenewdate is in the format "2020-12-31 23:59", we only want the date
    Map.put(map, "soonestrenewdate", String.split(soonest, " ") |> List.first())
  end
  defp truncate_soonestrenewdate(map), do: map

  defp remap_issue_note(%{"note" => ""} = map), do: Map.put(map, "loan_type", "HOME_LOAN")
  defp remap_issue_note(%{"note" => "Läsesalslån"} = map), do: Map.put(map, "loan_type", "READING_ROOM")
  defp remap_issue_note(%{"note" => "Forskarskåpslån"} = map), do: Map.put(map, "loan_type", "RESEARCH_LOCKER")
  defp remap_issue_note(%{"note" => "Institutionslån"} = map), do: Map.put(map, "loan_type", "DEPARTMENT_LOAN")
  defp remap_issue_note(map), do: Map.put(map, "loan_type", "HOME_LOAN")
end
