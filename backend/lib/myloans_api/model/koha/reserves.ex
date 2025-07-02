defmodule MyloansApi.Model.Koha.Reserves do
  alias MyloansApi.Model.Koha.Common
  alias MyloansApiWeb.AuthenticationHelper, as: AuthHelp
  import MyloansApi.KohaModelHelpers

  def cancel(cardnumber, reserve_id) do
    params = %{
      login_userid: Common.username(),
      login_password: Common.password(),
      reserve_id: reserve_id,
      cardnumber: cardnumber
    }
    body_params = URI.encode_query(params)

    case koha_post_request(url_cancel(), body_params) do
      {:ok, response_body} ->
        {:ok, XmlToMap.naive_map(response_body) }
      {:error, reason} ->
        {:error, reason}
    end
  end

  def url_cancel() do
    Common.base_url() <> "/cgi-bin/koha/svc/reserves/delete"
  end
end
