defmodule Ozfarium.Gallery.Ozfa do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ozfarium.Users.UserOzfa
  alias Ozfarium.Users.UserOzfaTag

  schema "ozfas" do
    has_many :user_ozfas, UserOzfa
    has_many :users, through: [:user_ozfas, :user]
    has_one :owner_user_ozfa, UserOzfa, where: [owned: true]
    has_one :owner, through: [:owner_user_ozfa, :user]

    has_many :user_ozfa_tags, UserOzfaTag

    field :type, :string, null: false, default: "image"
    field :content, :string
    field :url, :string
    field :hash, :string
    field :width, :integer
    field :height, :integer

    field :duplicate?, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(ozfa, attrs) do
    ozfa
    |> cast(attrs, [:type, :url, :content, :hash, :width, :height])
    |> validate_required([:type])
  end
end
