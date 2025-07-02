defmodule MyloansApi.Resource.Renewals do
  alias MyloansApi.Model.Koha

  def renew(id, itemnumbers) do
    Koha.Renewals.renew(id, itemnumbers)
  end
end
