defmodule CatOnDutyWeb.LiveHelpers do
  @moduledoc "Live view helpers"

  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `CatOnDutyWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal CatOnDutyWeb.TeamLive.FormComponent,
        id: @team.id || :new,
        action: @live_action,
        team: @team,
        return_to: Routes.team_index_path(@socket, :index) %>
  """
  def live_modal(component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(CatOnDutyWeb.ModalComponent, modal_opts)
  end
end
