defmodule MyloansApi.Repo do
  use Ecto.Repo,
    otp_app: :myloans_api,
    adapter: Ecto.Adapters.Postgres
end
