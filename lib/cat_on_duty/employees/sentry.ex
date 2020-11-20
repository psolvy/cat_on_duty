defmodule CatOnDuty.Employees.Sentry do
  @moduledoc "Sentry model"

  use Ecto.Schema
  import Ecto.Changeset
  import CatOnDuty.Gettext

  alias CatOnDuty.Employees.Team

  @type t :: %__MODULE__{
          id: pos_integer,
          name: String.t(),
          tg_username: String.t(),
          on_vacation?: boolean,
          last_duty_at: DateTime.t() | nil,
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "sentries" do
    field(:name, :string)
    field(:tg_username, :string)
    field(:on_vacation?, :boolean, default: false)
    field(:last_duty_at, :utc_datetime)

    belongs_to(:team, Team)
    has_one(:today_duty, Team, foreign_key: :today_sentry_id, on_delete: :nilify_all)

    timestamps()
  end

  @spec changeset(Ecto.Changeset.t() | __MODULE__.t(), %{
          name: String.t(),
          team_id: pos_integer(),
          tg_username: String.t(),
          on_vacation?: boolean()
        }) :: Ecto.Changeset.t()
  def changeset(sentry, attrs) do
    sentry
    |> cast(attrs, ~w[name team_id tg_username on_vacation?]a)
    |> validate_required(~w[name tg_username on_vacation?]a)
    |> validate_format(:tg_username, ~r/^@/, message: dgettext("errors", "must starts with '@'"))
  end

  @spec last_duty_at_changeset(Ecto.Changeset.t() | __MODULE__.t(), %{last_duty_at: DateTime.t()}) ::
          Ecto.Changeset.t()
  def last_duty_at_changeset(sentry, attrs) do
    sentry
    |> cast(attrs, ~w[last_duty_at]a)
    |> validate_required(~w[last_duty_at]a)
  end
end
