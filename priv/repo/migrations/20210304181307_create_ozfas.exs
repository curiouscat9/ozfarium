defmodule Ozfarium.Repo.Migrations.CreateOzfas do
  use Ecto.Migration

  def change do
    create table(:ozfas) do
      add :type, :string, null: false
      add :url, :string
      add :content, :text

      timestamps()
    end

    create index(:ozfas, [:type])
  end
end
