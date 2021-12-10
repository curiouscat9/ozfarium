defmodule Ozfarium.Repo.Migrations.AddFieldsForImagesToOzfas do
  use Ecto.Migration

  def change do
    alter table(:ozfas) do
      add :hash, :string
      add :width, :integer
      add :height, :integer
    end
  end
end
