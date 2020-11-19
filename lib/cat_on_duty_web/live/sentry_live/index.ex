defmodule CatOnDutyWeb.SentryLive.Index do
  use CatOnDutyWeb, :live_view

  alias CatOnDuty.{Employees, Employees.Sentry}

  @impl true
  def mount(_params, _session, socket) do
    Employees.subscribe()

    {:ok,
     socket
     |> assign(:search, "")
     |> fetch()}
  end

  @impl true
  def handle_info({Employees, [:sentry | _], _}, %{assigns: %{search: search}} = socket)
      when search != "",
      do: {:noreply, socket}

  def handle_info({Employees, [:team | _], _}, %{assigns: %{search: search}} = socket)
      when search != "",
      do: {:noreply, socket}

  def handle_info({Employees, [:sentry | _], _}, socket), do: {:noreply, fetch(socket)}

  def handle_info({Employees, [:team | _], _}, socket), do: {:noreply, fetch(socket)}

  @impl true
  def handle_params(params, _url, socket),
    do: {:noreply, apply_action(socket, socket.assigns.live_action, params)}

  @impl true
  def handle_event("search", %{"search" => %{"term" => term}}, socket) do
    search_term = String.trim(term)

    {:noreply,
     socket
     |> assign(:search, search_term)
     |> assign(:sentries, Employees.filter_sentries(search_term))}
  end

  defp apply_action(socket, :new_sentry, _params) do
    socket
    |> assign(:page_title, dgettext("form", "New sentry"))
    |> assign(:sentry, %Sentry{})
  end

  defp apply_action(socket, :index, _params),
    do: assign(socket, :page_title, dgettext("sentry", "Sentries"))

  defp fetch(socket), do: assign(socket, :sentries, Employees.list_sentries())
end
