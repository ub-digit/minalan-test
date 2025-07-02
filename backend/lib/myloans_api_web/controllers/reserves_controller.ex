defmodule MyloansApiWeb.ReservesController do
  use MyloansApiWeb, :controller
  alias MyloansApi.Resource.Reserves
  alias MyloansApiWeb.AuthenticationHelper, as: AuthHelp

  def cancel(%Plug.Conn{private: %{ authenticated: false }} = conn, _) do
    conn
    |> AuthHelp.set_auth_required()
    |> json(%{error: "Not authorized"})
  end
  def cancel(%Plug.Conn{private: %{ current_user: %{ login: cardnumber }}} = conn, %{"id" => reserve_id}) do
    result = Reserves.cancel(cardnumber, reserve_id)
    cancel_response(conn, result)
  end
  def cancel(%Plug.Conn{private: %{ authenticated: true }} = conn, _) do
    conn
    |> AuthHelp.set_forbidden()
    |> json(%{error: "Forbidden"})
  end

  def cancel_response(conn, {:error, :not_found}) do
    conn
    |> Plug.Conn.put_status(404)
    |> json(%{"error" => "Not found"})
  end
  def cancel_response(conn, {:error, _}) do
    conn
    |> Plug.Conn.put_status(500)
    |> json(%{"error" => "An error occured"})
  end
  def cancel_response(conn, {:ok, status}), do: json(conn, status)
end
