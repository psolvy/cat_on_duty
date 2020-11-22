defmodule CatOnDutyWeb.RotateTodaySentryAndNotify do
  @moduledoc "Serviice that provides functions for rotation and team or all teams today sentry"

  import CatOnDuty.Gettext

  alias CatOnDuty.{Employees, Employees.Sentry, Employees.Team}

  @business_days [1, 2, 3, 4, 5]

  @spec for_all_teams :: {:ok, :rotated} | {:error, :not_business_day}
  def for_all_teams do
    if Timex.weekday(Timex.today()) in @business_days do
      Employees.list_teams()
      |> Enum.each(&for_team(&1.id))

      {:ok, :rotated}
    else
      {:error, :not_business_day}
    end
  end

  @spec for_team(pos_integer) :: {:ok, pid}
  def for_team(id) do
    Task.start_link(fn ->
      {:ok, _} =
        id
        |> Employees.get_team!()
        |> rotate_today_sentry()

      notify_about_new_today_sentry(id)
    end)
  end

  @spec rotate_today_sentry(Team.t()) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  defp rotate_today_sentry(team) do
    case most_rested_team_sentry(team) do
      nil ->
        Employees.update_team_today_sentry(team, %{today_sentry_id: nil})

      %Sentry{} = most_rested ->
        {:ok, _} = Employees.update_sentry_last_duty_at(most_rested, %{last_duty_at: Timex.now()})

        Employees.update_team_today_sentry(team, %{today_sentry_id: most_rested.id})
    end
  end

  @spec most_rested_team_sentry(Team.t()) :: Sentry.t() | nil
  defp most_rested_team_sentry(%Team{id: id}) do
    case Employees.team_sentries_not_on_vacation_sorted_by_last_duty_at(id) do
      [] ->
        nil

      [most_rested | _] ->
        most_rested
    end
  end

  @spec notify_about_new_today_sentry(pos_integer) ::
          {:ok, Nadia.Model.Message.t()} | {:error, :not_sended}
  defp notify_about_new_today_sentry(id) do
    case Employees.get_team!(id) do
      %Team{today_sentry: %Sentry{}} = team ->
        notify(team, 0)

      _team_without_today_sentry ->
        {:ok, :no_sentry}
    end
  end

  @spec notify(Team.t(), 0..6) :: {:ok, Nadia.Model.Message.t()} | {:error, :not_sended}
  defp notify(_team, 6), do: {:error, :not_sended}

  defp notify(%Team{today_sentry: sentry, tg_chat_id: chat_id} = team, retry) do
    case Nadia.send_message(
           String.to_integer(chat_id),
           dgettext("telegram", "❗Today's duty is on %{name}(%{username})",
             name: sentry.name,
             username: sentry.tg_username
           )
         ) do
      {:ok, _result} = res ->
        res

      {:error, %Nadia.Model.Error{reason: "Bad Request: chat not found"}} ->
        {:error, :not_sended}

      {:error, _error} ->
        :timer.sleep(5000)

        notify(team, retry + 1)
    end
  end
end
