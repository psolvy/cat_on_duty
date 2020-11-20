defmodule CatOnDutyWeb.RotateTodaySentryAndNotify do
  @moduledoc "Serviice that provides functions for team today sentry rotation "

  import CatOnDuty.Gettext
  alias CatOnDuty.{Employees, Employees.Sentry, Employees.Team}

  @business_days [1, 2, 3, 4, 5]

  def teams() do
    if Timex.weekday(Timex.today()) in @business_days do
      Employees.list_teams()
      |> Enum.each(&team(&1.id))
    else
      {:ok, :not_business_day}
    end
  end

  def team(id) do
    {:ok, _} = Employees.rotate_team_today_sentry(id)

    notify_team_about_new_today_sentry(id)
  end

  defp notify_team_about_new_today_sentry(id) do
    case Employees.get_team!(id) do
      %Team{today_sentry: %Sentry{}} = team ->
        Task.start_link(fn -> notify(team, 0) end)

      _team_without_today_sentry ->
        nil
    end
  end

  defp notify(_team, 6), do: {:ok, :not_sended}

  defp notify(%Team{today_sentry: sentry, tg_chat_id: chat_id} = team, retry) do
    case Nadia.send_message(
           chat_id,
           dgettext("telegram", "❗Today's duty is on %{name}(%{username})",
             name: sentry.name,
             username: sentry.tg_username
           )
         ) do
      {:ok, _result} = res ->
        res

      {:error, %Nadia.Model.Error{reason: "Please wait a little"}} ->
        :timer.sleep(5000)

        notify(team, retry + 1)

      {:error, %Nadia.Model.Error{reason: "Bad Request: chat not found"}} ->
        {:ok, :not_sended}
    end
  end
end
