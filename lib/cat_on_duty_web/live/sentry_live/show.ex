defmodule CatOnDutyWeb.SentryLive.Show do
  @moduledoc "Sentry show page handlers"

  use CatOnDutyWeb, :live_view

  alias CatOnDuty.Employees

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    :ok = Employees.subscribe()

    {:ok, fetch(socket, id)}
  end

  @impl true
  def handle_info(
        {Employees, [:sentry, :deleted], %{id: deleted_id}},
        %{assigns: %{sentry: sentry}} = socket
      ) do
    if deleted_id == sentry.id do
      {:noreply,
       socket
       |> push_redirect(to: Routes.sentry_index_path(socket, :index))}
    else
      {:noreply, socket}
    end
  end

  def handle_info(
        {Employees, [:sentry | _], %{id: updated_id}},
        %{assigns: %{sentry: sentry}} = socket
      ) do
    if updated_id == sentry.id do
      {:noreply, fetch(socket, sentry.id)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(
        {Employees, [:team | _], %{id: updated_team_id}},
        %{assigns: %{sentry: sentry}} = socket
      ) do
    if updated_team_id == sentry.team_id do
      {:noreply, fetch(socket, sentry.id)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    sentry = Employees.get_sentry!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action, sentry))
     |> assign(:sentry, sentry)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, _} =
      id
      |> Employees.get_sentry!()
      |> Employees.delete_sentry()

    {:noreply,
     socket
     |> put_flash(:info, dgettext("flash", "Sentry deleted"))
     |> push_redirect(to: Routes.sentry_index_path(socket, :index))}
  end

  @spec page_title(:show | :edit_sentry, Employees.Sentry.t()) :: String.t()
  defp page_title(:show, sentry), do: sentry.name

  defp page_title(:edit_sentry, _sentry), do: dgettext("form", "Edit sentry")

  @spec fetch(Phoenix.LiveView.Socket.t(), pos_integer) :: Phoenix.LiveView.Socket.t()
  defp fetch(socket, id), do: assign(socket, :sentry, Employees.get_sentry!(id))
end
