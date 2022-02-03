defmodule Ozfarium.Users do
  import Ecto.Query, warn: false

  alias Ozfarium.Repo

  alias Ozfarium.Users.User
  alias Ozfarium.Users.UserOzfaTag

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

  @doc """
  Returns the list of user_ozfa_tags.

  ## Examples

      iex> list_user_ozfa_tags()
      [%UserOzfaTag{}, ...]

  """
  def list_user_ozfa_tags do
    Repo.all(UserOzfaTag)
  end

  @doc """
  Gets a single user_ozfa_tag.

  Raises `Ecto.NoResultsError` if the User ozfa tag does not exist.

  ## Examples

      iex> get_user_ozfa_tag!(123)
      %UserOzfaTag{}

      iex> get_user_ozfa_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_ozfa_tag!(id), do: Repo.get!(UserOzfaTag, id)

  def get_user_ozfa_tag(user, ozfa, tag) do
    from(uot in UserOzfaTag,
      where: uot.user_id == ^user.id and uot.ozfa_id == ^ozfa.id and uot.tag_id == ^tag.id
    )
    |> Repo.one()
  end

  @doc """
  Creates a user_ozfa_tag.

  ## Examples

      iex> create_user_ozfa_tag(%{field: value})
      {:ok, %UserOzfaTag{}}

      iex> create_user_ozfa_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_ozfa_tag(attrs \\ %{}) do
    %UserOzfaTag{}
    |> UserOzfaTag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_ozfa_tag.

  ## Examples

      iex> update_user_ozfa_tag(user_ozfa_tag, %{field: new_value})
      {:ok, %UserOzfaTag{}}

      iex> update_user_ozfa_tag(user_ozfa_tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_ozfa_tag(%UserOzfaTag{} = user_ozfa_tag, attrs) do
    user_ozfa_tag
    |> UserOzfaTag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_ozfa_tag.

  ## Examples

      iex> delete_user_ozfa_tag(user_ozfa_tag)
      {:ok, %UserOzfaTag{}}

      iex> delete_user_ozfa_tag(user_ozfa_tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_ozfa_tag(%UserOzfaTag{} = user_ozfa_tag) do
    Repo.delete(user_ozfa_tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_ozfa_tag changes.

  ## Examples

      iex> change_user_ozfa_tag(user_ozfa_tag)
      %Ecto.Changeset{data: %UserOzfaTag{}}

  """
  def change_user_ozfa_tag(%UserOzfaTag{} = user_ozfa_tag, attrs \\ %{}) do
    UserOzfaTag.changeset(user_ozfa_tag, attrs)
  end

  def rate_ozfa(user, ozfa, tag, rating) do
    case get_user_ozfa_tag(user, ozfa, tag) do
      nil ->
        create_user_ozfa_tag(%{user_id: user.id, ozfa_id: ozfa.id, tag_id: tag.id, rating: rating})

      user_ozfa_tag ->
        update_user_ozfa_tag(user_ozfa_tag, %{rating: rating})
    end
  end
end
