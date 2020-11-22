import Config

config :cat_on_duty, CatOnDuty.Scheduler,
  jobs: [
    # Everyday at 7:00 UTC
    {"0 7 * * *", {CatOnDutyWeb.RotateTodaySentryAndNotify, :for_all_teams, []}}
  ]
