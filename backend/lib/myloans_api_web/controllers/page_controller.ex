defmodule MyloansApiWeb.PageController do
  use MyloansApiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
