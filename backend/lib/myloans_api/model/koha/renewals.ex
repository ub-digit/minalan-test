defmodule MyloansApi.Model.Koha.Renewals do
  alias MyloansApi.Model.Koha.Common
  import MyloansApi.KohaModelHelpers

  def renew(id, itemnumbers) do
    params = %{
      login_userid: Common.username(),
      login_password: Common.password(),
      borrower: id,
      itemnumbers: Enum.join(itemnumbers, ":")
    }
    body_params = URI.encode_query(params)

    case koha_post_request(url_renew(), body_params) do
      {:ok, response_body} ->
        {:ok, Jason.decode!(response_body) }
      {:error, reason} ->
        {:error, reason}
    end
  end

  def url_renew() do
    Common.base_url() <> "/cgi-bin/koha/svc/members/dorenew"
  end
end
