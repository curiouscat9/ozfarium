defmodule Ozfarium.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :authenticated_at, :naive_datetime
    field :first_name, :string
    field :last_name, :string
    field :telegram_id, :integer
    field :telegram_photo_url, :string
    field :telegram_username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :first_name,
      :last_name,
      :telegram_id,
      :telegram_username,
      :telegram_photo_url,
      :authenticated_at
    ])
    |> validate_required([])
    |> unique_constraint(:telegram_id)
  end
end
