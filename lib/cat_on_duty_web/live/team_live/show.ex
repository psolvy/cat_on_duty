defmodule CatOnDutyWeb.TeamLive.Show do
  @moduledoc "Team show page handlers"

  use CatOnDutyWeb, :live_view

  alias CatOnDuty.{Employees, Employees.Sentry, Employees.Team}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    :ok = Employees.subscribe()

    {:ok, fetch(socket, id)}
  end

  @impl true
  def handle_info(
        {Employees, [:team, :deleted], %{id: deleted_id}},
        %{assigns: %{team: team}} = socket
      ) do
    if deleted_id == team.id do
      {:noreply,
       socket
       |> push_redirect(to: Routes.team_index_path(socket, :index))}
    else
      {:noreply, socket}
    end
  end

  def handle_info(
        {Employees, [:team | _], %{id: updated_id}},
        %{assigns: %{team: team}} = socket
      ) do
    if updated_id == team.id do
      {:noreply, fetch(socket, team.id)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({Employees, [:sentry | _], _}, %{assigns: %{team: team}} = socket),
    do: {:noreply, fetch(socket, team.id)}

  @impl true
  def handle_params(%{"id" => id, "sentry_id" => sentry_id}, _, socket) do
    team = Employees.get_team!(id)
    sentry = Employees.get_sentry!(sentry_id)

    {:noreply,
     socket
     |> assign(:team, team)
     |> apply_action(socket.assigns.live_action, sentry)}
  end

  def handle_params(%{"id" => id}, _, socket) do
    team = Employees.get_team!(id)

    {:noreply,
     socket
     |> assign(:team, team)
     |> apply_action(socket.assigns.live_action, team)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, _} =
      id
      |> Employees.get_team!()
      |> Employees.delete_team()

    {:noreply,
     socket
     |> put_flash(:info, dgettext("flash", "Team deleted"))
     |> push_redirect(to: Routes.team_index_path(socket, :index))}
  end

  def handle_event("delete_sentry", %{"id" => id}, socket) do
    sentry = Employees.get_sentry!(id)

    {:ok, _} = Employees.delete_sentry(sentry)

    team = Employees.get_team!(sentry.team_id)

    {:noreply,
     socket
     |> put_flash(:info, dgettext("flash", "Sentry deleted"))
     |> assign(:team, team)}
  end

  def handle_event("rotate_today_sentry", %{"id" => id}, socket) do
    {:ok, _} = CatOnDutyWeb.RotateTodaySentryAndNotify.for_team(id)

    {:noreply,
     socket
     |> put_flash(:info, dgettext("flash", "Team today sentry rotated"))
     |> fetch(id)}
  end

  @spec apply_action(Phoenix.LiveView.Socket.t(), :show | :edit | :new_sentry, map) ::
          Phoenix.LiveView.Socket.t()
  defp apply_action(socket, :show, %Team{name: name}), do: assign(socket, :page_title, name)

  defp apply_action(socket, :edit, %Team{}),
    do: assign(socket, :page_title, dgettext("form", "Edit team"))

  defp apply_action(socket, :new_sentry, %Team{}) do
    socket
    |> assign(:page_title, dgettext("form", "New sentry"))
    |> assign(:sentry, %Sentry{})
  end

  defp apply_action(socket, :edit_sentry, %Sentry{} = sentry) do
    socket
    |> assign(:page_title, dgettext("form", "Edit sentry"))
    |> assign(:sentry, sentry)
  end

  @spec fetch(Phoenix.LiveView.Socket.t(), pos_integer) :: Phoenix.LiveView.Socket.t()
  defp fetch(socket, id), do: assign(socket, :team, Employees.get_team!(id))
end
