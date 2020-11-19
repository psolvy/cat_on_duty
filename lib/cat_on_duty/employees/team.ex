defmodule CatOnDuty.Employees.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias CatOnDuty.Employees.Sentry

  schema "teams" do
    field :name, :string
    field :tg_chat_id, :string

    has_many :sentries, Sentry, on_delete: :nilify_all
    belongs_to :today_sentry, Sentry

    timestamps()
  end

  def changeset(team, attrs) do
    team
    |> cast(attrs, ~w[name tg_chat_id]a)
    |> validate_required(~w[name tg_chat_id]a)
  end

  def today_sentry_changeset(team, attrs) do
    team
    |> cast(attrs, ~w[today_sentry_id]a)
  end
end
