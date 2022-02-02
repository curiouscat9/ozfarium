defmodule Ozfarium.Tags.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ozfarium.Users.User

  schema "tags" do
    belongs_to :user, User

    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name])
  end
end
