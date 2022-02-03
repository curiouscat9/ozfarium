defmodule Ozfarium.Repo.Migrations.CreateUserOzfaTags do
  use Ecto.Migration

  def change do
    create table(:user_ozfa_tags) do
      add :rating, :integer, null: false
      add :user_id, references(:users, on_delete: :delete_all)
      add :ozfa_id, references(:ozfas, on_delete: :delete_all)
      add :tag_id, references(:tags, on_delete: :delete_all)

      timestamps()
    end

    create index(:user_ozfa_tags, [:rating])
    create index(:user_ozfa_tags, [:tag_id, :user_id])
    create unique_index(:user_ozfa_tags, [:user_id, :ozfa_id, :tag_id])
  end
end
