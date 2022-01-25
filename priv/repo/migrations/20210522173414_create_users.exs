defmodule Ozfarium.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :telegram_id, :integer
      add :telegram_username, :string
      add :telegram_photo_url, :string
      add :authenticated_at, :naive_datetime

      timestamps()
    end

    create unique_index(:users, :telegram_id)
  end
end
