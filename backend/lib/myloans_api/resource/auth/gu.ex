defmodule MyloansApi.Resource.Auth.GU do
  def authenticate(code) do
    fetch_gu_token(code)
    # Token is now a JWT to be decoded to get the userdata
    |> fetch_gu_userdata()
    |> fetch_koha_userdata()
    |> create_session()
  end

  defp fetch_gu_token(code) do
    token_body = %{
      code: code,
      grant_type: "authorization_code",
      redirect_uri: System.get_env("OAUTH2_REDIRECT_URI") || "http://localhost:8080/login/GU"
    }
    secret = System.get_env("OAUTH2_CLIENT_SECRET")
    client_id = System.get_env("OAUTH2_CLIENT_ID")
    client_base64 = Base.encode64(client_id <> ":" <> secret)
    token_endpoint = System.get_env("OAUTH2_TOKEN_ENDPOINT")
    token_body = URI.encode_query(token_body)
    token_headers = [
      {"Content-type", "application/x-www-form-urlencoded"},
      {"Authorization", "Basic " <> client_base64}
    ]
    resp = HTTPoison.post!(token_endpoint, token_body, token_headers)
    case Jason.decode!(resp.body) do
      %{"error" => error} -> {:error, error}
      %{"access_token" => token} -> {:ok, :token, token}
      _ -> {:error, :missing_access_token}
    end
  end

  defp fetch_gu_userdata({:error, status}), do: {:error, status}
  defp fetch_gu_userdata({:ok, :token, jwt_token}) do
    # Decode the JWT token
    JWTDecoder.decode(jwt_token)
    |> Map.get(:payload)
    |> case do
      %{"account" => account} -> {:ok, :login_success, account}
      _ -> {:error, :gu_userdata_fail}
    end
  end

  defp fetch_koha_userdata({:error, status}), do: {:error, status}
  defp fetch_koha_userdata({:ok, :login_success, username}) do
    koha_patron_query = %{
      borrower: username,
      login_userid: System.get_env("KOHA_API_USERNAME"),
      login_password: System.get_env("KOHA_API_PASSWORD")
    }

    koha_patron_url = System.get_env("KOHA_BASE_URL") <> "/cgi-bin/koha/svc/members/getless?" <> URI.encode_query(koha_patron_query)
    HTTPoison.get!(koha_patron_url, [{"Accept", "text/xml"}])
    |> case do
      %{status_code: 404} -> {:error, :user_not_found}
      response ->
        case Jason.decode!(response.body)["borrower"] do
          %{"email" => email, "borrowernumber" => id, "firstname" => firstname, "surname" => surname, "cardnumber" => cardnumber} ->
            name = [firstname, surname] |> Enum.join(" ")
            {:ok, %{"email" => email, "id" => id, "login" => cardnumber, "name" => name, "source_id" => Kernel.to_string(id)}}
          _ -> {:error, :userdata_fail}
        end
    end
  end

  defp create_session({:error, status}), do: {:error, status}
  defp create_session({:ok, userdata}) do
    {user, access_token} = MyloansApi.Resource.User.fetch_or_create("koha-" <> UUID.uuid4, userdata)
    userdata = MyloansApi.Model.User.remap(user)
    {:ok, userdata, access_token}
  end
end
