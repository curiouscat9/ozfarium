defmodule Ozfarium.Users.UserOzfa do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ozfarium.Users.User
  alias Ozfarium.Gallery.Ozfa

  schema "user_ozfas" do
    belongs_to :user, User
    belongs_to :ozfa, Ozfa

    field :owned, :boolean, default: false
    field :hidden, :boolean, default: false
    field :ep_timestamps, {:array, :naive_datetime}, default: []
    
    timestamps()
  end

  def sum_of_last_minute_ep_timestamps(user_ozfas, current_time) do
    Enum.reduce(user_ozfas, 0, fn user_ozfa, acc ->
      recent_timestamps = Enum.filter(user_ozfa.ep_timestamps, fn timestamp ->
        NaiveDateTime.diff(current_time, timestamp) <= 60
      end)
      acc + length(recent_timestamps)
    end)
  end


  @doc false
  def changeset(user_ozfa, attrs) do
    user_ozfa
    |> cast(attrs, [:user_id, :ozfa_id, :owned, :hidden, :ep_timestamps])
    |> validate_required([:user_id, :ozfa_id, :owned, :hidden, :ep_timestamps])
  end
end
