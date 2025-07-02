defmodule MyloansApi.Model.Alert do
  def get_from_file() do
    File.read!("data/alert.json")
    |> Jason.decode!()
  end

  def get() do
    # Fetch from Koha. KOHA_BASE_URL/cgi-bin/koha/svc/config/get for MyLoansAlertMessage
    # Use HTTPoison to fetch the data
    # Use Jason to parse the JSON
    # If the request fails, return the data from the file
    # If the JSON fails to parse, return the data from the file

    response = HTTPoison.get(koha_alert_url())
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decode(body)
      _ ->
        get_from_file()
    end
  end

  defp decode(body) do
    IO.inspect(body)
    case Jason.decode(body) do
      {:ok, decoded} -> decoded |> extract_message()
      _ -> get_from_file()
    end
  end

  # Message is a map with "preference" and "value" keys
  # We are interested in "value" content, which must also be parsed as JSON
  defp extract_message(%{"preference" => "MyLoansAlertMessage", "value" => value}) do
    case Jason.decode(value) do
      {:ok, decoded} -> decoded
      _ -> get_from_file()
    end
  end

  defp koha_alert_url() do
    base_url = System.get_env("KOHA_BASE_URL")
    koha_api_username = System.get_env("KOHA_API_USERNAME")
    koha_api_password = System.get_env("KOHA_API_PASSWORD")
    "#{base_url}/cgi-bin/koha/svc/config/get?login_userid=#{koha_api_username}&login_password=#{koha_api_password}&pref=MyLoansAlertMessage"
  end
end
