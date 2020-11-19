defmodule CatOnDutyWeb.SentryLive.FormComponent do
  use CatOnDutyWeb, :live_component

  alias CatOnDuty.Employees

  @impl true
  def update(%{sentry: sentry} = assigns, socket) do
    changeset = Employees.change_sentry(sentry)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:teams, Employees.list_teams())}
  end

  @impl true
  def handle_event("validate", %{"sentry" => sentry_params}, socket) do
    changeset =
      socket.assigns.sentry
      |> Employees.change_sentry(sentry_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"sentry" => sentry_params}, socket) do
    save_sentry(socket, socket.assigns.action, sentry_params)
  end

  defp save_sentry(socket, :edit_sentry, sentry_params) do
    case Employees.update_sentry(socket.assigns.sentry, sentry_params) do
      {:ok, _sentry} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("flash", "Sentry changed"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_sentry(socket, :new_sentry, sentry_params) do
    sentry_params
    |> Map.put("team_id", socket.assigns.team.id)
    |> handle_sentry_creation(socket)
  end

  defp save_sentry(socket, :new, sentry_params) do
    handle_sentry_creation(sentry_params, socket)
  end

  defp handle_sentry_creation(sentry_params, socket) do
    case Employees.create_sentry(sentry_params) do
      {:ok, _sentry} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("flash", "Sentry added"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
