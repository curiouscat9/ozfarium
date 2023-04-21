defmodule Ozfarium.Repo.Migrations.AddEpCountToUserOzfas do
  use Ecto.Migration

  def change do
    alter table(:user_ozfas) do
      add :ep_timestamps, {:array, :naive_datetime}
    end
  end
end