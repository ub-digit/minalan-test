defmodule MyloansApiWeb.Router do
  use MyloansApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    # plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug MyloansApiWeb.AuthPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MyloansApiWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/setup/:item", SetupController, :show
    post "/renewals/:id", RenewalsController, :renew
    delete "/reserves/:id", ReservesController, :cancel
    get "/patrons/:id", PatronController, :show
    put "/patrons/:id", PatronController, :update
    post "/password", PatronController, :password_validation
    get "/charges/:id", ChargesController, :show
    get "/auth/user", AuthController, :user
    get "/auth/refresh", AuthController, :refresh
    post "/auth/:provider", AuthController, :auth
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyloansApiWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: MyloansApiWeb.Telemetry
    end
  end
end
