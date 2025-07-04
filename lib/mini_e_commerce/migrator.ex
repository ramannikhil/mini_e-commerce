defmodule MiniECommerce.Migrator do
  @moduledoc """
  The migrator module for the exam management application.
  This module is used to migrate the database at startup.
  """
  @app :mini_e_commerce
  def migrate do
    for repo <- repos() do
      opts = Application.get_env(@app, repo)
      repo.__adapter__().storage_up(opts)
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def seed_data do
    seed_file = Path.join([:code.priv_dir(:mini_e_commerce), "repo", "seeds.exs"])

    if File.exists?(seed_file) do
      IO.puts("Running seed script...")
      Code.eval_file(seed_file)
    else
      IO.puts("No seed file found.")
    end
  end

  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
