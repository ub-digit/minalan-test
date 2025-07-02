defmodule MyloansApi.Resource.Patron.Remap.Flags do
  def remap({:error, error}), do: {:error, error}
  def remap({:ok, map}) do
    remapped =
      map["flags"]
      |> Enum.filter(fn {key, _} -> Enum.member?(flag_fields(), key) end)
      |> Map.new()

    {:ok, Map.put(map, "flags", remapped)}
  end

  defp flag_fields() do
    [ "CHARGES", "DBARRED" ]
  end
end
