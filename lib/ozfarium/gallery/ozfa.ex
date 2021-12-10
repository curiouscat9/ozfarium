defmodule Ozfarium.Gallery.Ozfa do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ozfas" do
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
