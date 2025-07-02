defmodule MyloansApi.Model.Koha.Charges do
  alias MyloansApi.Model.Koha.Common
  import MyloansApi.KohaModelHelpers

  def fetch(%{} = input_params) do
    params = Map.merge(%{
      login_userid: Common.username(),
      login_password: Common.password(),
    }, input_params)

    case koha_get_request(url_get(params)) do
      {:ok, response_body} ->
        {:ok, Jason.decode!(response_body) }
      {:error, reason} ->
        {:error, reason}
    end

  end
  def fetch(id), do: fetch(%{borrower: id})

  def url_get(params) do
    Common.base_url() <> "/cgi-bin/koha/svc/members/getcharges?" <> URI.encode_query(params)
  end
end
