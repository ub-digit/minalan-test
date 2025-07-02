defmodule MyloansApi.Resource.Auth.CAS do
  def authenticate(ticket, service) do
    validate_cas_ticket(ticket, service)
    |> fetch_koha_userdata()
    |> create_session()
  end

  defp validate_cas_ticket(ticket, service) do
    cas_params = %{
      ticket: ticket,
      service: service
    }
    cas_validate_url = System.get_env("CAS_VALIDATE_URL") <> "?" <> URI.encode_query(cas_params)

    cas_response = HTTPoison.get!(cas_validate_url, [{"Accept", "text/xml"}])
    cas_data = XmlToMap.naive_map(cas_response.body) |> strip_cas_response_prefix()
    case cas_data do
      %{"serviceResponse" => %{"authenticationSuccess" => %{"user" => username}}} -> {:ok, :login_success, username}
      _ -> {:error, :cas_authentication_error}
    end
  end

  defp strip_cas_response_prefix(map) do
    map
    |> Enum.map(fn {key, value} ->
      new_key = Regex.replace(~r/^{[^}]+}/, key, "")
      new_value =
        case value do
          %{} = map_value -> strip_cas_response_prefix(map_value)
          other -> other
        end
      {new_key, new_value}
    end)
    |> Map.new()
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
