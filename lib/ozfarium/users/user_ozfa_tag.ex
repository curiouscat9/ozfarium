defmodule Ozfarium.Users.UserOzfaTag do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ozfarium.Users.User
  alias Ozfarium.Gallery.Ozfa
  alias Ozfarium.Tags.Tag

  schema "user_ozfa_tags" do
    belongs_to :user, User
    belongs_to :ozfa, Ozfa
    belongs_to :tag, Tag

    field :rating, :integer

    timestamps()
  end

  @doc false
  def changeset(user_ozfa_tag, attrs) do
    user_ozfa_tag
    |> cast(attrs, [:rating, :user_id, :ozfa_id, :tag_id])
    |> validate_required([:rating])
  end
end
