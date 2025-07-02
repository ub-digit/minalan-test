defmodule MyloansApi.Resource.Common do
  def is_blank(nil), do: true
  def is_blank(val) when val == %{}, do: true
  def is_blank(val) when val == [], do: true
  def is_blank(val) when is_binary(val), do: String.trim(val) == ""
  def is_blank(_), do: false
end
