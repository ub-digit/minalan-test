defmodule MyloansApiWeb.ChargesController do
  use MyloansApiWeb, :controller
  alias MyloansApi.Resource.Charges
  alias MyloansApiWeb.AuthenticationHelper, as: AuthHelp

  def show(%Plug.Conn{private: %{ authenticated: false }} = conn, _) do
    conn
    |> AuthHelp.set_auth_required()
    |> json(%{error: "Not authorized"})
  end
  def show(%Plug.Conn{private: %{ current_user: %{ login: id }}} = conn, %{"id" => id}) do
    charges = Charges.fetch(id)
    show_response(conn, charges)
  end
  def show(%Plug.Conn{private: %{ authenticated: true }} = conn, _) do
    conn
    |> AuthHelp.set_forbidden()
    |> json(%{error: "Forbidden"})
  end

  def show_response(conn, {:error, :not_found}) do
    conn
    |> Plug.Conn.put_status(404)
    |> json(%{"error" => "Not found"})
  end
  def show_response(conn, {:error, _}) do
    conn
    |> Plug.Conn.put_status(500)
    |> json(%{"error" => "An error occured"})
  end
  def show_response(conn, {:ok, charges}), do: json(conn, charges)

end
