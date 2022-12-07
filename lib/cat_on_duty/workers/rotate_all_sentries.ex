defmodule CatOnDuty.Workers.RotateAllSentries do
  @moduledoc "Workewr that starts rotation for all teams"

  use Oban.Worker, queue: :rotation

  alias CatOnDuty.Services.RotateTodaySentryAndNotify

  @impl Oban.Worker
  def perform(_job) do
    RotateTodaySentryAndNotify.for_all_teams()

    :ok
  end
end
