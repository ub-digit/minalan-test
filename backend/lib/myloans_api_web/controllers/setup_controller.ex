defmodule MyloansApiWeb.SetupController do
  use MyloansApiWeb, :controller
  alias MyloansApi.Resource.Setup

  def show(conn, %{"item" => "translations"}) do
    translations = Setup.fetch("translations")
    json(conn, translations)
  end

  def show(conn, %{"item" => "settings"}) do
    settings = Setup.fetch("settings")
    json(conn, settings)
  end

  def show(conn, %{"item" => "alert"}) do
    alert = Setup.fetch("alert")
    json(conn, alert)
  end
end
