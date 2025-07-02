defmodule MyloansApi.Resource.Patron.Remap.Attributes do
  def remap({:error, error}), do: {:error, error}
  def remap({:ok, map}) do
    remapped =
      map["attributes"]
      |> Enum.map(fn %{"attribute" => attribute, "code" => code} -> {String.downcase(code), attribute} end)
      |> Enum.filter(fn {key, _} -> Enum.member?(attribute_fields(), key) end)
      |> Map.new()

    {map, remapped} = move_pin_to_borrower(map, remapped)
    {map, remapped} = move_anun_to_borrower(map, remapped)

    {:ok, Map.put(map, "attributes", remapped)}
  end

  defp attribute_fields() do
    [ "accept", "pnr", "pin", "anun" ]
  end

  # Movie ANUN attribute to borrower, but use the name "survey_acceptance" instead.
  # It should be a string "yes" or "no".
  # If the attribute does not exist, create it with the value "yes".
  # If it contains "0", set it to "no".
  # If it contains "1", set it to "yes".
  # If it contains anything else, set it to "yes".
  defp move_anun_to_borrower(map, attributes) do
    anun = Map.get(attributes, "anun")
    # Remove from attributes
    attributes = Map.delete(attributes, "anun")
    # Add to borrower
    borrower = Map.get(map, "borrower")
    borrower = Map.put(borrower, "survey_acceptance", set_value(anun))
    {Map.put(map, "borrower", borrower), attributes}
  end

  defp set_value(_current = nil), do: "yes"
  defp set_value(_current = "0"), do: "no"
  defp set_value(_current = "1"), do: "yes"
  defp set_value(_current = "yes"), do: "yes"
  defp set_value(_current = "no"), do: "no"
  defp set_value(_current), do: "yes"

  defp move_pin_to_borrower(map, attributes) do
    pin = Map.get(attributes, "pin")
    # Remove from attributes
    attributes = Map.delete(attributes, "pin")
    # Add to borrower
    borrower = Map.get(map, "borrower")
    borrower = Map.put(borrower, "pin", pin)
    {Map.put(map, "borrower", borrower), attributes}
  end
end
