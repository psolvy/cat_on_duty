defmodule CatOnDutyWeb.PageLive do
  use CatOnDutyWeb, :live_view

  @impl true
  def render(assigns) do
    ~L"""
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, push_redirect(socket, to: Routes.team_index_path(socket, :index))}
  end
end
