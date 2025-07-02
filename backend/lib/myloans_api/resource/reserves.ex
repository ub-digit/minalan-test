defmodule MyloansApi.Resource.Reserves do
  alias MyloansApi.Model.Koha

  def cancel(cardnumber, reserve_id) do
    Koha.Reserves.cancel(cardnumber, reserve_id)
    |> case do
      {:ok, %{"response" => result}} -> {:ok, result}
      {:error, error} -> {:error, error}
    end
  end
end
