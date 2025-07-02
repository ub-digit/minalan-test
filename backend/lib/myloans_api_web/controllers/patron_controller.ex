defmodule MyloansApiWeb.PatronController do
  use MyloansApiWeb, :controller
  alias MyloansApi.Resource.Patron
  alias MyloansApiWeb.AuthenticationHelper, as: AuthHelp
  require Logger

  def show(%Plug.Conn{private: %{ authenticated: false }} = conn, _) do
    conn
    |> AuthHelp.set_auth_required()
    |> json(%{error: "Not authorized"})
  end
  def show(%Plug.Conn{private: %{ current_user: %{ login: id }}} = conn, %{"id" => id} = params) do
    mode = params["mode"] || "brief"
    patron = Patron.fetch(id, mode)
    show_response(conn, patron)
  end
  def show(%Plug.Conn{private: %{ authenticated: true }} = conn, _) do
    conn
    |> AuthHelp.set_forbidden()
    |> json(%{error: "Forbidden"})
  end

  def update(%Plug.Conn{private: %{ authenticated: false }} = conn, _) do
    conn
    |> AuthHelp.set_auth_required()
    |> json(%{error: "Not authorized"})
  end
  def update(conn, %{"id" => id, "patron" => %{} = patron}) do
    result = Patron.save(id, patron)
    update_response(conn, result)
  end
  def update(%Plug.Conn{private: %{ authenticated: true }} = conn, _) do
    conn
    |> AuthHelp.set_forbidden()
    |> json(%{error: "Forbidden"})
  end

  def password_validation(%Plug.Conn{private: %{ authenticated: false }} = conn, _) do
    conn
    |> AuthHelp.set_auth_required()
    |> json(%{error: "Not authorized"})
  end
  # {"status":"VALIDATION_ERROR","error":{"password":["too_short", "require_digit"], "password2":["dont_match"]}}
  # {"status":"OK", "message":"Password is valid"}
  def password_validation(conn, %{"password" => password, "password2" => password2}) do
    result = Patron.Writer.validate_password_interactive(password, password2)
    case result do
      {:ok, message} -> json(conn, %{"status" => "OK", "message" => message})
      {:invalid, errors} -> AuthHelp.validation_error(conn) |> json(%{"status" => "VALIDATION_ERROR", "error" => errors})
    end
  end
  def password_validation(%Plug.Conn{private: %{ authenticated: true }} = conn, _) do
    conn
    |> AuthHelp.set_forbidden()
    |> json(%{error: "Forbidden"})
  end

  def update_response(conn, {:error, :not_found}) do
    conn
    |> Plug.Conn.put_status(404)
    |> json(%{"error" => "Not found"})
  end
  def update_response(conn, {:error, _}) do
    conn
    |> Plug.Conn.put_status(500)
    |> json(%{"error" => "An error occured"})
  end
  def update_response(conn, {:invalid, validation_data}) do
    conn
    |> AuthHelp.validation_error()
    |> json(%{"error" => "VALIDATION_ERROR", "validation_data" => validation_data})
  end
  def update_response(conn, {:ok, patron}), do: json(conn, %{"patron" => patron})

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
  def show_response(conn, {:ok, patron}), do: json(conn, patron)
end
