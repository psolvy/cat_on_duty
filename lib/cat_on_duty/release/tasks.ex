defmodule CatOnDuty.Release.Tasks do
  @moduledoc false

  @start_apps [:postgrex, :ecto, :ecto_sql, :ssl]

  @myapps [:cat_on_duty]

  @spec migrate :: :ok
  def migrate do
    # Start apps necessary for executing migrations
    IO.puts("Starting dependencies...")
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    IO.puts("Start running migrations..")
    Enum.each(@myapps, &run_migrations_for/1)
    IO.puts("migrate task done!")
  end

  @spec run_migrations_for(atom) :: :ok
  def run_migrations_for(app) do
    IO.puts("Running migrations for '#{app}'")

    for repo <- get_repos(app) do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    IO.puts("Finished running migrations for '#{app}'")
  end

  @spec get_repos(atom) :: [module]
  defp get_repos(app) do
    Application.load(app)

    Application.fetch_env!(app, :ecto_repos)
  end

  @spec rollback(module, pos_integer) :: {:ok, any, any}
  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end
end
