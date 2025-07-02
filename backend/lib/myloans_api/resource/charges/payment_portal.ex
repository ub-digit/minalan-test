defmodule MyloansApi.Resource.Charges.PaymentPortal do
  import MyloansApi.Resource.Common

  @library_groups %{
    "44" => "G",
    "60" => "G",
    "62" => "G",
    "40" => "Gm",
    "43" => "Gm",
    "49" => "Gm",
    "66" => "Gm",
    "42" => "Gpek",
    "47" => "Gpek",
    "48" => "Gpek",
    "50" => "Gpek"
  }

  @fallback_library_group "Gpek"

  def remap_terms(map) do
    map
    |> Map.put("library_group", library_group(map["homebranch"]))
    |> Map.put("debit_type", debit_type(map["debit_type_code"]))
    |> Map.put("title", map["full_title"])
    |> Map.put("title_known", !is_blank(map["full_title"]))
  end

  defp debit_type("OVERDUE"), do: "fine"
  defp debit_type(_), do: "media"

  defp library_group(branchcode) do
    @library_groups[branchcode] || @fallback_library_group
  end

  def add_portal_properties(map) do
    uuid = UUID.uuid4() |> String.upcase()
    callback_url = System.get_env("KOHA_API_PAYMENT_CALLBACK_URL")
    payment_portal_url = System.get_env("KOHA_API_PAYMENT_PORTAL_URL")
    payment_disabled =
      case map["online_payment_state"] do
        "enabled" -> false
        "disabled" -> true
        _ -> false
      end

    map
    |> Map.put("callback_url", callback_url)
    |> Map.put("payment_portal_url", payment_portal_url)
    |> Map.put("uuid", uuid)
    |> Map.put("payment_disabled", payment_disabled)
  end
end
