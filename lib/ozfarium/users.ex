defmodule Ozfarium.Users do
  alias Ozfarium.Repo
  alias Ozfarium.Users.User

  def get_user(id) do
    Repo.get(User, id)
  end

  def get_user_by_telegram_id(id) do
    Repo.get_by(User, %{telegram_id: id})
  end

  def create_user_from_telegram_params(params) do
    User.changeset(%User{}, %{
      first_name: params["first_name"],
      last_name: params["last_name"],
      telegram_id: params["id"] |> String.to_integer(),
      telegram_username: params["username"],
      telegram_photo_url: params["photo_url"],
      authenticated_at: params["auth_date"] |> String.to_integer() |> DateTime.from_unix!()
    })
    |> Repo.insert()
  end
end
