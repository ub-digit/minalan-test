defmodule MyloansApi.Resource.Patron do
  alias MyloansApi.Model.Koha
  alias MyloansApi.Resource.Patron.Remap
  alias MyloansApi.Resource.Patron.Writer

  def fetch(params), do: fetch(params, "brief")
  def fetch(%{} = input_params, mode) do
    Koha.Patron.fetch(input_params, mode)
    |> Remap.Attributes.remap()
    |> Remap.Borrower.remap()
    |> Remap.Flags.remap()
    |> Remap.Debarments.remap()
    |> combine()
    |> Remap.Issues.remap("issues")
    |> Remap.Issues.remap("overdues")
    |> Remap.Holds.remap()
  end
  def fetch(userid, mode), do: fetch(%{"borrower" => userid}, mode)

  def combine({:error, error}), do: {:error, error}
  def combine({:ok, %{"message_preference" => msg_prefs} = map}) do
    preference =
      msg_prefs
      |> Enum.sort()
      |> Enum.join("_")

    borrower =
      Map.get(map, "borrower")
      |> Map.put("attributes", map["attributes"])
      |> Map.put("message_preference", preference)
      |> Map.put("can_pay_online", patron_can_pay(map["borrower"]["categorycode"]))
      |> Map.put("has_local_pin", patron_has_local_pin(map["borrower"]["categorycode"], map["borrower"]["cardnumber"]))
      |> Map.put("has_local_password", patron_has_local_password(map["borrower"]["categorycode"], map["borrower"]["cardnumber"]))
      |> Map.put("allow_password_change", patron_allow_password_change(map))
      |> Map.put("allow_survey_acceptance", patron_allow_survey_acceptance(map["borrower"]["categorycode"]))
      |> Map.put("can_issue", patron_can_issue(map))
      |> Map.put("can_renew", patron_can_renew(map))
      |> Map.put("can_autorenew", patron_can_autorenew(map))
      |> Map.put("pickup_code", patron_pickup_code(map))
      |> Map.put("can_change_firstname", patron_can_change_firstname(map))

    map =
      map
      |> Map.put("borrower", borrower)
      |> Map.delete("attributes")
      |> Map.delete(("message_preference"))
    {:ok, map}
  end

  def save(id, data) do
    Writer.save(id, data)
  end

  defp patron_can_pay(categorycode) do
    !Enum.member?(["BA","BE","BF","BK","BL","BM","BN","BU","EI","TN","TJ","PE"], categorycode)
  end

  # Local pin if external patron or if cardnumber starts with "3" (local library card)
  def patron_has_local_pin(categorycode, cardnumber) do
    # Replace this line
    is_external(categorycode) || has_local_library_card(cardnumber)
    # With this line to disable local library card feature
    # is_external(categorycode)
  end

  defp is_external(categorycode) do
    Enum.member?(["EX", "EM", "UX", "FR", "FX", "SR"], categorycode)
  end

  defp has_local_library_card(cardnumber) do
    String.starts_with?(cardnumber, "3")
  end

  # Only allow password change for external patrons ("EX", "UX", "FR", "FX", "SR")
  def patron_has_local_password(categorycode, _cardnumber) do
    is_external(categorycode)
  end

  # Check if password change is allowed at all (enabled by ENV variable "ALLOW_PASSWORD_CHANGE")
  def patron_allow_password_change(map) do
    System.get_env("ALLOW_PASSWORD_CHANGE") == "true"
  end

  def patron_allow_survey_acceptance(categorycode) do
    System.get_env("SHOW_SURVEY_ACCEPTANCE") == "true" && is_external(categorycode)
  end

  # Only external can change first name
  def patron_can_change_firstname(map) do
    categorycode = map["borrower"]["categorycode"]
    is_external(categorycode)
  end

  # Fetch the patron's first name and last name from the borrower map
  # and return the last name and first name initials.
  # If either the first name or last name is missing, return an empty string for that initial.
  defp patron_initials(borrower) do
    first_name = Map.get(borrower, "firstname", "")
    last_name = Map.get(borrower, "surname", "")
    first_initial = if first_name == "", do: "", else: String.at(first_name, 0)
    last_initial = if last_name == "", do: "", else: String.at(last_name, 0)
    last_initial <> first_initial |> String.upcase()
  end

  # Get the patrons initials, and the last 4 digits of the cardnumber
  # and return that as the patron's pickup code
  defp patron_pickup_code(%{"borrower" => borrower}) do
    initials = patron_initials(borrower)
    cardnumber = Map.get(borrower, "cardnumber", "")
    last_4 = String.slice(cardnumber, -4..-1)
    # return initials + digits if ENV variable SHOW_PICKUP_CODE is set to "true"
    # otherwise return nil
    if System.get_env("SHOW_PICKUP_CODE") == "true" do
      initials <> last_4
    else
      nil
    end
  end

  defp patron_can_issue(%{"flags" => %{"CHARGES" => %{"noissues" => 1}}}) do
    %{
      "allowed" => false,
      "reason" => "FINES_EXCEEDED"
    }
  end
  defp patron_can_issue(%{"debarments" => debarments}) do
    debarments
    |> Enum.find(fn debarment -> debarment["type"] == "CARD_EXPIRED" end)
    |> case do
      %{"type" => type} -> %{
        "allowed" => false,
        "reason" => type
      }
      _ -> %{"allowed" => true}
    end
  end
  defp patron_can_issue(_), do: %{"allowed" => true}

  defp patron_can_renew(%{"flags" => %{"CHARGES" => %{"norenewals" => 1}}}) do
    %{
      "allowed" => false,
      "reason" => "FINES_EXCEEDED"
    }
  end
  defp patron_can_renew(%{"debarments" => debarments}) do
    debarments
    |> Enum.find(fn debarment -> debarment["type"] == "CARD_EXPIRED" end)
    |> case do
      %{"type" => type} -> %{
        "allowed" => false,
        "reason" => type
      }
      _ -> %{"allowed" => true}
    end
  end
  defp patron_can_renew(_), do: %{"allowed" => true}

  defp patron_can_autorenew(%{"flags" => %{"CHARGES" => %{"noautorenewals" => 1}}}) do
    %{
      "allowed" => false,
      "reason" => "FINES_EXCEEDED"
    }
  end
  defp patron_can_autorenew(_), do: %{"allowed" => true}
end
