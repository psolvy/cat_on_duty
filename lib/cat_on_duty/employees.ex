defmodule CatOnDuty.Employees do
  @moduledoc "Team and Sentry context"

  import Ecto.Query, warn: false
  alias CatOnDuty.Repo

  alias CatOnDuty.Employees.{Sentry, Team}

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(CatOnDuty.PubSub, @topic)
  end

  def list_teams(query \\ Team) do
    query
    |> order_by(asc: :id)
    |> Repo.all()
    |> Repo.preload([:today_sentry])
  end

  def filter_teams(search_term) do
    wildcard_search = "%#{search_term}%"

    query = from(t in Team, where: ilike(t.name, ^wildcard_search))

    list_teams(query)
  end

  def rotate_team_today_sentry(team_id) do
    case most_rested_team_sentry(team_id) do
      nil ->
        team_id
        |> get_team!()
        |> update_team_today_sentry(nil)

      most_rested ->
        {:ok, _} = update_sentry_last_duty_at(most_rested, %{last_duty_at: Timex.now()})

        team_id
        |> get_team!()
        |> update_team_today_sentry(most_rested.id)
    end
  end

  defp most_rested_team_sentry(team_id) do
    case team_sentries_not_on_vacation_sorted_by_last_duty_at(team_id) do
      [] ->
        nil

      [most_rested | _] ->
        most_rested
    end
  end

  defp team_sentries_not_on_vacation_sorted_by_last_duty_at(team_id) do
    Sentry
    |> where([s], s.team_id == ^team_id)
    |> where([s], not s.on_vacation?)
    |> Repo.all()
    |> Enum.sort_by(& &1.last_duty_at)
  end

  def get_team!(id) do
    sentries_query =
      from(s in Sentry,
        order_by: [:on_vacation?, :last_duty_at]
      )

    team_query =
      from(t in Team,
        preload: [sentries: ^sentries_query],
        preload: :today_sentry
      )

    Repo.get(team_query, id)
  end

  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
    |> broadcast_change([:team, :created])
  end

  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
    |> broadcast_change([:team, :updated])
  end

  defp update_team_today_sentry(%Team{} = team, sentry_id) do
    team
    |> Team.today_sentry_changeset(%{today_sentry_id: sentry_id})
    |> Repo.update()
    |> broadcast_change([:team, :updated])
  end

  def delete_team(%Team{} = team) do
    team
    |> Repo.delete()
    |> broadcast_change([:team, :deleted])
  end

  def change_team(%Team{} = team, attrs \\ %{}), do: Team.changeset(team, attrs)

  def list_sentries(query \\ Sentry) do
    query
    |> order_by(asc: :id)
    |> Repo.all()
    |> Repo.preload(:team)
  end

  def filter_sentries(search_term) do
    wildcard_search = "%#{search_term}%"

    query =
      from(s in Sentry,
        where: ilike(s.name, ^wildcard_search),
        or_where: ilike(s.tg_username, ^wildcard_search)
      )

    list_sentries(query)
  end

  def get_sentry!(id) do
    Sentry
    |> Repo.get!(id)
    |> Repo.preload(:team)
  end

  def create_sentry(attrs \\ %{}) do
    %Sentry{}
    |> Sentry.changeset(attrs)
    |> Repo.insert()
    |> broadcast_change([:sentry, :created])
  end

  def update_sentry(%Sentry{} = sentry, attrs) do
    sentry
    |> Sentry.changeset(attrs)
    |> Repo.update()
    |> broadcast_change([:sentry, :updated])
  end

  defp update_sentry_last_duty_at(%Sentry{} = sentry, attrs) do
    sentry
    |> Sentry.last_duty_at_changeset(attrs)
    |> Repo.update()
    |> broadcast_change([:sentry, :updated])
  end

  def delete_sentry(%Sentry{} = sentry) do
    sentry
    |> Repo.delete()
    |> broadcast_change([:sentry, :deleted])
  end

  def change_sentry(%Sentry{} = sentry, attrs \\ %{}), do: Sentry.changeset(sentry, attrs)

  defp broadcast_change({:ok, result}, event) do
    :ok = Phoenix.PubSub.broadcast(CatOnDuty.PubSub, @topic, {__MODULE__, event, result})

    {:ok, result}
  end

  defp broadcast_change({:error, changeset}, _event), do: {:error, changeset}
end
