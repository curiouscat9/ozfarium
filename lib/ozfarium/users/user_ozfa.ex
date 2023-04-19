defmodule Ozfarium.Users.UserOzfa do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ozfarium.Users.User
  alias Ozfarium.Gallery.Ozfa

  schema "user_ozfas" do
    belongs_to :user, User
    belongs_to :ozfa, Ozfa

    field :owned, :boolean, default: false
    field :hidden, :boolean, default: false
    field :ep_count, {:array, :naive_datetime}, default: []
    
    timestamps()
  end

  @doc false
  def changeset(user_ozfa, attrs) do
    user_ozfa
    |> cast(attrs, [:user_id, :ozfa_id, :owned, :hidden, :ep_count])
    |> validate_required([:user_id, :ozfa_id, :owned, :hidden, :ep_count])
  end
end
