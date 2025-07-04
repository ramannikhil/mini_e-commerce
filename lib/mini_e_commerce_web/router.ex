defmodule MiniECommerceWeb.Router do
  use MiniECommerceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MiniECommerceWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MiniECommerceWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/login", SessionController, :new
    post "/session", SessionController, :create
    delete "/logout", SessionController, :delete
  end

  live_session :default, on_mount: MiniECommerceWeb.InitAssigns do
    scope "/live", MiniECommerceWeb do
      pipe_through :browser

      live "/list", Product.List
      live "/detail/:id", Product.Detail
    end
  end

  live_session :admin,
    on_mount: [
      {MiniECommerceWeb.Hooks.AuthenticateAdmin, :admin_auth}
    ] do
    scope "/live/admin", MiniECommerceWeb.Admin do
      pipe_through :browser

      live "/home", Home

      scope "/products" do
        live "/create", Product.Create
        live "/update", Product.Update
        live "/delete", Product.Delete
      end

      scope "/inventory" do
        live "/create", Inventory.Create
        live "/update", Inventory.Update
      end

      # live "/dashboard", Admin.DashboardLive
      # live "/products", Admin.ProductsLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", MiniECommerceWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:mini_e_commerce, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MiniECommerceWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
