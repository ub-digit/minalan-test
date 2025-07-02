defmodule MyloansApi.Model.Koha.Common do
  def base_url() do
    System.get_env("KOHA_BASE_URL")
  end

  def username() do
    System.get_env("KOHA_API_USERNAME")
  end

  def password() do
    System.get_env("KOHA_API_PASSWORD")
  end
end
