defmodule Ozfarium.Gallery.Ozfa do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ozfas" do
    field :type, :string, null: false
    field :content, :string
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(ozfa, attrs) do
    ozfa
    |> cast(attrs, [:type, :url, :content])
    |> validate_required([:type])
  end
end
