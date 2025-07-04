defmodule MiniECommerce.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MiniECommerceWeb.Telemetry,
      MiniECommerce.Repo,
      {DNSCluster, query: Application.get_env(:mini_e_commerce, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MiniECommerce.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: MiniECommerce.Finch},
      # Start a worker by calling: MiniECommerce.Worker.start_link(arg)
      # {MiniECommerce.Worker, arg},
      # Start to serve requests, typically the last entry
      {MiniECommerce.Genserver.LiveCounter, name: MiniECommerce.Genserver.LiveCounter},
      MiniECommerceWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MiniECommerce.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MiniECommerceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
