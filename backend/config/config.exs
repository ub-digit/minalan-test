# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :myloans_api,
  ecto_repos: [MyloansApi.Repo]

# Configures the endpoint
config :myloans_api, MyloansApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ar3lpmg3IJkFrhq0QFOgO6QTLpfrNDDv8LldFYGvb0A7RO6yfnztubAD0pPON3zu",
  render_errors: [view: MyloansApiWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MyloansApi.PubSub,
  live_view: [signing_salt: "6wCSAeC+"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
