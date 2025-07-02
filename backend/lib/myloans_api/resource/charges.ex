defmodule MyloansApi.Resource.Charges do
  alias MyloansApi.Model.Koha
  alias MyloansApi.Resource.Charges.PaymentPortal
  import MyloansApi.Resource.Common

  def fetch(%{} = input_params) do
    Koha.Charges.fetch(input_params)
    |> remap()
  end
  def fetch(userid), do: fetch(%{"borrower" => userid})

  def remap({:error, error}), do: {:error, error}
  def remap({:ok, map}) do
    remapped =
      map["account_lines"]
      |> Enum.map(&remap_charge/1)

    map =
      map
      |> Map.put("account_lines", remapped)
      |> PaymentPortal.add_portal_properties()

    {:ok, map}
  end

  defp remap_charge(%{"biblio_data" => biblio_data} = map) do
    map
    |> Map.put("title", biblio_data["title"])
    |> Map.put("subtitle", biblio_data["subtitle"])
    |> Map.put("author", biblio_data["author"])
    |> Map.delete("biblio_data")
    |> remap_charge()
  end
  defp remap_charge(%{"item_data" => item_data} = map) do
    map
    |> Map.put("homebranch", item_data["homebranch"])
    |> Map.put("barcode", item_data["barcode"])
    |> Map.delete("item_data")
    |> remap_charge()
  end
  defp remap_charge(map) do
    map
    |> remap_date("date")
    |> add_full_title()
    |> remap_amount()
    |> PaymentPortal.remap_terms()
    |> is_payable()
  end

  defp add_full_title(map) do
    full_title =
      [map["title"], map["subtitle"]]
      |> Enum.reject(&is_blank/1)
      |> Enum.join(" ")
    Map.put(map, "full_title", full_title)
  end

  defp remap_amount(map) do
    amount_outstanding =
      map["amountoutstanding"]
      |> String.to_float()
      |> :erlang.float_to_binary(decimals: 2)

    Map.put(map, "amount", amount_outstanding)
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

  defp is_payable(%{"debit_type_code" => "LOST"} = map), do: Map.put(map, "payable", true)
  defp is_payable(%{"debit_type_code" => "A"} = map), do: Map.put(map, "payable", true)
  defp is_payable(%{"debit_type_code" => "OVERDUE", "status" => "RETURNED"} = map),
    do: Map.put(map, "payable", true)
  defp is_payable(%{"debit_type_code" => "OVERDUE", "status" => "LOST"} = map),
    do: Map.put(map, "payable", true)
  defp is_payable(%{"debit_type_code" => "OVERDUE", "status" => "RENEWED"} = map),
    do: Map.put(map, "payable", true)
  defp is_payable(map), do: Map.put(map, "payable", false)

end
