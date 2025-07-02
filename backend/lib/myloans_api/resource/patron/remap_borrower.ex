defmodule MyloansApi.Resource.Patron.Remap.Borrower do
  def remap({:error, error}), do: {:error, error}
  def remap({:ok, map}) do
    remapped =
      map["borrower"]
      |> Enum.filter(fn {key, _} -> Enum.member?(borrower_fields(), key) end)
      |> Enum.map(&remap_borrower_keys/1)
      |> Map.new()

    {:ok, Map.put(map, "borrower", remapped)}
  end

  defp borrower_fields() do
    [
      "borrowernumber", "firstname", "surname", "cardnumber", "dateexpiry", "categorycode",
      "address", "address2", "city", "zipcode", "B_address", "B_address2", "B_city", "B_zipcode",
      "smsalertnumber", "phone", "email", "lost", "gonenoaddress", "pin", "lang", "survey_acceptance"
    ]
  end

  defp remap_borrower_keys({"dateexpiry", value}), do: {"expire_date", value}
  defp remap_borrower_keys({"lang", nil}), do: {"lang", "sv-SE"}
  defp remap_borrower_keys({"lang", ""}), do: {"lang", "sv-SE"}
  defp remap_borrower_keys({"lang", "default"}), do: {"lang", "sv-SE"}
  defp remap_borrower_keys({key, value}), do: {String.downcase(key), value}
  defp remap_borrower_keys(other), do: other
end
