defmodule MyloansApiWeb.RenewalsController do
  use MyloansApiWeb, :controller
  alias MyloansApi.Resource.Renewals
  alias MyloansApiWeb.AuthenticationHelper, as: AuthHelp

  def renew(%Plug.Conn{private: %{ authenticated: false }} = conn, _) do
    conn
    |> AuthHelp.set_auth_required()
    |> json(%{error: "Not authorized"})
  end
  def renew(conn, %{"id" => id, "itemnumbers" => itemnumbers}) do
    result = Renewals.renew(id, itemnumbers)
    renew_response(conn, result)
  end
  def renew(%Plug.Conn{private: %{ authenticated: true }} = conn, _) do
    conn
    |> AuthHelp.set_forbidden()
    |> json(%{"error" => "Forbidden"})
  end

  def renew_response(conn, {:error, :not_found}) do
    conn
    |> Plug.Conn.put_status(404)
    |> json(%{"error" => "Not found"})
  end
  def renew_response(conn, {:error, _}) do
    conn
    |> Plug.Conn.put_status(500)
    |> json(%{"error" => "An error occured"})
  end
  def renew_response(conn, {:ok, statuses}), do: json(conn, statuses)
end
