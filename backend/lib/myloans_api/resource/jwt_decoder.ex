defmodule JWTDecoder do
  @doc """
  Decodes a JWT token without verifying the signature.
  Returns a map with `header` and `payload` keys.
  """
  def decode(jwt) do
    [header, payload, _signature] = String.split(jwt, ".")

    %{
      header: decode_segment(header),
      payload: decode_segment(payload)
    }
  end

  defp decode_segment(segment) do
    segment
    |> String.replace("-", "+")
    |> String.replace("_", "/")
    |> Base.decode64!(padding: false)
    |> Jason.decode!()
  end

  # DEBUG purpose, read from /tmp/gu_token_response.txt
  # Parse the JSON response from the file
  # Decode the JWT token from the JSON response
  def read_file() do
    File.read!("/tmp/gu_token_response.txt")
    |> Jason.decode!()
    |> Map.get("access_token")
    |> decode()
  end
end
