defmodule Ozfarium.Repo.Migrations.CreateUserOzfas do
  use Ecto.Migration

  def change do
    create table(:user_ozfas) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :ozfa_id, references(:ozfas, on_delete: :delete_all)

      add :owned, :boolean, default: false, null: false
      add :hidden, :boolean, default: false, null: false

      timestamps()
    end

    create index(:user_ozfas, [:user_id])
    create index(:user_ozfas, [:ozfa_id])
    create unique_index(:user_ozfas, [:user_id, :ozfa_id])
  end
end
