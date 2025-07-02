defmodule MyloansApi.Resource.Patron.Remap.Holds do
  import MyloansApi.Resource.Common

  def remap({:error, error}), do: {:error, error}
  def remap({:ok, %{"holds" => _} = map}) do
    remapped =
      map["holds"]
      |> Enum.map(&remap_hold/1)
      |> Enum.sort_by(fn %{"priority" => priority, "reservedate" => reservedate} -> {priority, reservedate} end)

    {:ok, Map.put(map, "holds", remapped)}
  end
  def remap({:ok, map}), do: {:ok, map}

  def remap_hold(%{"biblio_data" => biblio_data} = map) do
    map
    |> Map.put("title", biblio_data["title"])
    |> Map.put("subtitle", biblio_data["subtitle"])
    |> Map.put("author", biblio_data["author"])
    |> Map.delete("biblio_data")
    |> remap_hold()
  end
  def remap_hold(%{"item_data" => item_data} = map) do
    map
    |> Map.put("onloan", item_data["onloan"] != nil)
    |> Map.delete("item_data")
    |> remap_hold()
  end
  def remap_hold(map) do
    map
    |> Enum.filter(fn {key, _} -> Enum.member?(hold_fields(), key) end)
    |> Map.new()
    |> add_full_title()
    |> remap_status()
    |> can_be_cancelled()
    |> reserve_loan_type()
    |> show_pickup_location()
    |> is_waiting()
  end

  defp remap_status(%{"found" => "W"} = map), do: Map.put(map, "status", "WAITING")
  defp remap_status(%{"found" => "T"} = map), do: Map.put(map, "status", "TRANSIT")
  defp remap_status(%{"found" => "P"} = map), do: Map.put(map, "status", "PROCESSING")
  defp remap_status(%{"itemnumber" => inum, "onloan" => false} = map)
    when not(is_nil(inum)),
    do: Map.put(map, "status", "REQUESTED")
  defp remap_status(map), do: Map.put(map, "status", "UNFILLED")

  defp can_be_cancelled(map), do: Map.put(map, "can_be_cancelled", true)
  # The old rules, commented out for now, until the new permissive version is tested and approved
  # Comment out the line above and uncommment these to restore the old rules
  # defp can_be_cancelled(%{"priority" => 0} = map), do: Map.put(map, "can_be_cancelled", false)
  # defp can_be_cancelled(%{"status" => "UNFILLED"} = map), do: Map.put(map, "can_be_cancelled", true)
  # defp can_be_cancelled(%{"status" => "REQUESTED"} = map), do: Map.put(map, "can_be_cancelled", true)
  # defp can_be_cancelled(map), do: Map.put(map, "can_be_cancelled", false)

  defp is_waiting(%{"status" => "WAITING"} = map), do: Map.put(map, "is_waiting", true)
  defp is_waiting(map), do: Map.put(map, "is_waiting", false)

  defp reserve_loan_type(%{"reservenotes" => reservenotes} = map) when is_binary(reservenotes) do
    loan_type =
      cond do
        String.starts_with?(reservenotes, "Lånetyp: Skicka") -> "send_home"
        String.starts_with?(reservenotes, "Lånetyp: Skicka hem") -> "send_home"
        String.starts_with?(reservenotes, "Lånetyp: Läsesal") -> "reading_room"
        String.starts_with?(reservenotes, "Lånetyp: Läs materialet i biblioteket") -> "reading_room"
        String.starts_with?(reservenotes, "Lånetyp: Hemlån") -> "home_loan"
        String.starts_with?(reservenotes, "Lånetyp: Hämta materialet i biblioteket ") -> "home_loan"
        String.starts_with?(reservenotes, "Lånetyp: Forskarskåp") -> "researcher_locker"
        String.starts_with?(reservenotes, "Lånetyp: Institutionslån") -> "department_loan"
        true -> "home_loan"
      end
    Map.put(map, "reserve_loan_type", loan_type)
  end
  defp reserve_loan_type(map), do: Map.put(map, "reserve_loan_type", "home_loan")

  defp show_pickup_location(%{"reserve_loan_type" => "send_home"} = map), do: Map.put(map, "show_pickup_location", false)
  defp show_pickup_location(map), do: Map.put(map, "show_pickup_location", true)

  defp add_full_title(map) do
    full_title =
      [map["title"], map["subtitle"]]
      |> Enum.reject(&is_blank/1)
      |> Enum.join(" ")
    Map.put(map, "full_title", full_title)
  end

  defp hold_fields() do
    [
      "biblionumber", "itemnumber", "title", "subtitle", "author",
      "found", "branchcode", "reserve_id", "reservedate", "priority",
      "expirationdate", "onloan", "waitingdate", "reservenotes"
    ]
  end
end
