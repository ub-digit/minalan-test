defmodule MyloansApi.Model.Koha.Patron do
  alias MyloansApi.Model.Koha.Common
  import MyloansApi.KohaModelHelpers

  def fetch(params), do: fetch(params, "brief")
  def fetch(%{} = input_params, mode) do
    params = Map.merge(%{
      login_userid: Common.username(),
      login_password: Common.password(),
    }, input_params)

    case koha_get_request(url_get(params, mode)) do
      {:ok, response_body} ->
        {:ok, Jason.decode!(response_body) }
      {:error, reason} ->
        {:error, reason}
    end
  end

  def fetch(id, mode), do: fetch(%{borrower: id}, mode)

  # Easier to interpret error, instead of ArgumentError,
  # when forgotten to load ENV-vars
  def url_get(%{login_userid: nil, login_password: nil}, _), do: raise "Invalid svc/members parameters"

  def url_get(params, "brief") do
    Common.base_url() <> "/cgi-bin/koha/svc/members/getless?" <> URI.encode_query(params)
  end
  def url_get(params, "full") do
    Common.base_url() <> "/cgi-bin/koha/svc/members/getmore?" <> URI.encode_query(params)
  end
  def url_update() do
    Common.base_url() <> "/cgi-bin/koha/svc/members/updatemore"
  end

  def update(id, input_params) do
    params = Map.merge(%{
      login_userid: Common.username(),
      login_password: Common.password(),
      id: id
    }, input_params)
    body_params = URI.encode_query(params)

    case koha_put_request(url_update(), body_params) do
      {:ok, response_body} ->
        {:ok, Jason.decode!(response_body) }
      {:error, reason} ->
        {:error, reason}
    end
  end
end
