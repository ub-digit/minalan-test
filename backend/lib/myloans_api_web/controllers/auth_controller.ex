defmodule MyloansApiWeb.AuthController do
  use MyloansApiWeb, :controller
  alias MyloansApiWeb.AuthenticationHelper, as: AuthHelp

  def auth(conn, params) do
    auth_result = MyloansApi.Resource.Auth.authenticate(params)
    auth_response(conn, auth_result)
  end

  defp auth_response(conn, {:ok, user, access_token}) do
    conn
    |> AuthHelp.add_authorization_header(access_token.session_key)
    |> json(%{data: user})
  end
  defp auth_response(conn, {:error, status} = auth_result) do
    conn
    |> AuthHelp.set_auth_required_on_error(auth_result)
    |> json(%{error: status})
  end

  def user(conn, _) do
    user = AuthHelp.fetch_authenticated_user(conn)
    user_response(conn, user)
  end

  defp user_response(conn, {:ok, user}), do: json(conn, %{data: user})
  defp user_response(conn, {:error, status} = auth_result) do
    conn
    |> AuthHelp.set_auth_required_on_error(auth_result)
    |> json(%{error: status})
  end

  def refresh(conn, _) do
    AuthHelp.get_session_key_from_header(conn)
    |> MyloansApi.Resource.User.refresh_token()

    json(conn, %{refreshed: true})
  end
end
