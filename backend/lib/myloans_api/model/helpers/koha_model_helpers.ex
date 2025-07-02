defmodule MyloansApi.KohaModelHelpers do
  require Logger

  def koha_get_request(url) do
    handle_response(
      HTTPoison.get(url, [], recv_timeout: 60000),
      [url: url, method: "GET"]
    )
  end

  def koha_post_request(url, body_params) do
    handle_response(
      HTTPoison.post(url, body_params, %{"Content-type" => "application/x-www-form-urlencoded"}, recv_timeout: 60000),
      [url: url, body_params: body_params, method: "POST"]
    )
  end

  def koha_put_request(url, body_params) do
    handle_response(
      HTTPoison.post(url, body_params, %{"Content-type" => "application/x-www-form-urlencoded"}, recv_timeout: 60000),
      [url: url, body_params: body_params, method: "PUT"]
    )
  end

  def handle_response({:ok, %HTTPoison.Response{body: content, status_code: 200}}, _) do
    {:ok, content}
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 404}}, logger_meta) do
    Logger.error("Koha service responded with 404", logger_meta)
    {:error, :not_found}
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: status_code, headers: headers}}, logger_meta) do
    Logger.error("Koha service responded with unexpected status code", logger_meta ++ [
      status_code: status_code,
      headers: headers
    ])
    {:error, :koha_service_error}
  end

  def handle_response({:error, %HTTPoison.Error{reason: reason}}, logger_meta) do
    Logger.error("An error occured performing Koha service request", logger_meta ++ [
      httpoison_error_reason: reason
    ])
    {:error, reason}
  end
end
