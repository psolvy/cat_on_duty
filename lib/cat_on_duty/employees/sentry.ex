defmodule CatOnDuty.Employees.Sentry do
  use Ecto.Schema
  import Ecto.Changeset
  import CatOnDuty.Gettext

  alias CatOnDuty.Employees.Team

  schema "sentries" do
    field :name, :string
    field :tg_username, :string
    field :on_vacation?, :boolean, default: false
    field :last_duty_at, :utc_datetime

    belongs_to :team, Team
    has_one :today_duty, Team, foreign_key: :today_sentry_id, on_delete: :nilify_all

    timestamps()
  end

  def changeset(sentry, attrs) do
    sentry
    |> cast(attrs, ~w[name team_id tg_username on_vacation?]a)
    |> validate_required(~w[name tg_username on_vacation?]a)
    |> validate_format(:tg_username, ~r/^@/, message: dgettext("errors", "must starts with '@'"))
  end

  def last_duty_at_changeset(sentry, attrs) do
    sentry
    |> cast(attrs, ~w[last_duty_at]a)
    |> validate_required(~w[last_duty_at]a)
  end
end
