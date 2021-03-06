defmodule CatOnDutyWeb.Router do
  use CatOnDutyWeb, :router

  import Phoenix.LiveDashboard.Router
  import Plug.BasicAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CatOnDutyWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :basic_auth, Application.compile_env(:cat_on_duty, :basic_auth)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CatOnDutyWeb do
    pipe_through :browser

    live_dashboard "/dashboard", metrics: CatOnDutyWeb.Telemetry

    live "/", PageLive, :index

    live "/teams", TeamLive.Index, :index
    live "/teams/new", TeamLive.Index, :new

    live "/teams/:id", TeamLive.Show, :show
    live "/teams/:id/edit", TeamLive.Show, :edit
    live "/teams/:id/new_sentry", TeamLive.Show, :new_sentry
    live "/teams/:id/edit_sentry/:sentry_id", TeamLive.Show, :edit_sentry

    live "/sentries", SentryLive.Index, :index
    live "/sentries/new", SentryLive.Index, :new_sentry

    live "/sentries/:id", SentryLive.Show, :show
    live "/sentries/:id/edit", SentryLive.Show, :edit_sentry
  end
end
