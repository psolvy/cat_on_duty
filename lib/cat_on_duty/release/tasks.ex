defmodule CatOnDuty.Release.Tasks do
  @moduledoc false
  @start_apps [:postgrex, :ecto, :ecto_sql, :ssl]

  @myapps [:cat_on_duty]

  def migrate() do
    # Start nessesary apps
    IO.puts("Starting dependencies...")

    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    IO.puts("Start running migrations..")
    Enum.each(@myapps, &run_migrations_for/1)
    IO.puts("migrate task done!")
  end

  def run_migrations_for(app) do
    IO.puts("Running migrations for '#{app}'")

    for repo <- get_repos(app) do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    IO.puts("Finished running migrations for '#{app}'")
  end

  defp get_repos(app) do
    Application.load(app)
    Application.fetch_env!(app, :ecto_repos)
  end

  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end
end
