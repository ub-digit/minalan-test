defmodule MyloansApi.Model.Koha.Pwreset do
  def url_update(username) do
    base_url = System.fetch_env!("KOHA_PWRESET_URL")
    sanitized_username = sanitize_username(username)
    "#{base_url}/#{sanitized_username}"
  end

  # ONLY numbers and letters A-Z and a-z are allowed in the username
  # Any other characters are removed
  defp sanitize_username(username) do
    Regex.replace(~r/[^a-zA-Z0-9]/, username, "")
  end

  def update(username, %{"password" => password}) do
    params = %{
      key: System.fetch_env!("KOHA_PWRESET_API_KEY"),
      password: password
    }
    body_params = URI.encode_query(params)

    case pwreset_put_request(url_update(username), body_params) do
      {:ok, response_body} ->
        {:ok, Jason.decode!(response_body) }
      {:error, reason} ->
        {:error, reason}
    end
  end

  def pwreset_put_request(url, body_params) do
    HTTPoison.put(url, body_params, %{"Content-type" => "application/x-www-form-urlencoded"}, recv_timeout: 60000)
    |> case do
      {:ok, %HTTPoison.Response{body: content, status_code: 200}} -> {:ok, content}
      {:ok, %HTTPoison.Response{status_code: 404}} -> {:error, :not_found}
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
    end
  end
end
