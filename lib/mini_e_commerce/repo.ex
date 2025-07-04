defmodule MiniECommerce.Repo do
  use Ecto.Repo,
    otp_app: :mini_e_commerce,
    adapter: Ecto.Adapters.Postgres
end
