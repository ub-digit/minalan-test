defmodule MyloansApi.Resource.Auth.Koha do
  def authenticate(cardnumber, password) do
    check_koha_auth(cardnumber, password)
    |> fetch_koha_userdata(cardnumber)
    |> create_session()
  end

  defp check_koha_auth(cardnumber, password) do
    koha_auth_query = %{
      login_userid: System.get_env("KOHA_API_USERNAME"),
      login_password: System.get_env("KOHA_API_PASSWORD"),
      cardnumber: cardnumber,
      user_password: password
    }

    koha_auth_url = System.get_env("KOHA_BASE_URL") <> "/cgi-bin/koha/svc/members/auth_password?" <> URI.encode_query(koha_auth_query)
    auth_response = HTTPoison.get!(koha_auth_url, [{"Accept", "text/xml"}])
    authdata = XmlToMap.naive_map(auth_response.body)

    case authdata["response"]["match"] do
      "true" -> {:ok, :login_success}
      _ -> {:error, :login_fail}
    end
  end

  defp fetch_koha_userdata({:error, status}, _), do: {:error, status}
  defp fetch_koha_userdata({:ok, :login_success}, cardnumber) do
    koha_patron_query = %{
      borrower: cardnumber,
      login_userid: System.get_env("KOHA_API_USERNAME"),
      login_password: System.get_env("KOHA_API_PASSWORD")
    }

    koha_patron_url = System.get_env("KOHA_BASE_URL") <> "/cgi-bin/koha/svc/members/getless?" <> URI.encode_query(koha_patron_query)
    userdata_resp = HTTPoison.get!(koha_patron_url, [{"Accept", "text/xml"}])
    userdata = Jason.decode!(userdata_resp.body)
    case userdata["borrower"] do
      %{"email" => email, "borrowernumber" => id, "firstname" => firstname, "surname" => surname} ->
        name = [firstname, surname] |> Enum.join(" ")
        stringified_id = Kernel.to_string(id)
        {:ok, %{"email" => email, "id" => stringified_id, "login" => cardnumber, "name" => name, "source_id" => stringified_id}}
      _ -> {:error, :userdata_fail}
    end
  end

  defp create_session({:error, status}), do: {:error, status}
  defp create_session({:ok, userdata}) do
    {user, access_token} = MyloansApi.Resource.User.fetch_or_create("koha-" <> UUID.uuid4, userdata)
    userdata = MyloansApi.Model.User.remap(user)
    {:ok, userdata, access_token}
  end
end
