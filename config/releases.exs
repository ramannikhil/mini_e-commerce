import Config

config :mini_e_commerce, MiniECommerce.Repo,
  url: System.fetch_env!("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

config :mini_e_commerce, MiniECommerceWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  url: [host: System.fetch_env!("RENDER_EXTERNAL_HOSTNAME"), port: 443],
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
  server: true
