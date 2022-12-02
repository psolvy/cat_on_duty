defmodule CatOnDutyWeb.PageLive do
  @moduledoc "Root path page handlers"

  use CatOnDutyWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""

    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, push_redirect(socket, to: Routes.team_index_path(socket, :index))}
  end
end
