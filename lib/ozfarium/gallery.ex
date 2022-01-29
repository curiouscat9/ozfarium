defmodule Ozfarium.Gallery do
  @moduledoc """
  The Gallery context.
  """

  import Ecto.Query, warn: false
  alias Ozfarium.Repo

  alias Ozfarium.Gallery.Queries
  alias Ozfarium.Gallery.Ozfa
  alias Ozfarium.Users.UserOzfa
  alias Ozfarium.Users.User

  @doc """
  Returns the list of ozfa ids.

  ## Examples

      iex> list_ozfas()
      [1, ...]

  """
  def list_ozfas(current_user, params \\ %{}) do
    from(o in Ozfa, select: o.id, order_by: [desc: o.inserted_at])
    |> Queries.my_ozfas(current_user, params)
    |> Repo.all()
  end

  def preload_missing_ozfas(user, preloaded_ozfas, ids) do
    case ids -- Map.keys(preloaded_ozfas) do
      [] -> preloaded_ozfas
      preload_ids -> Map.merge(preloaded_ozfas, preload_ozfas(user, preload_ids))
    end
  end

  def preload_ozfas(user, ids) do
    Queries.preload_ozfas(user, ids)
    |> Repo.all()
    |> Enum.reduce(%{}, fn o, acc ->
      Map.put(acc, o.id, o)
    end)
  end

  def preload_ozfa!(user, id) do
    Queries.preload_ozfas(user, [id])
    |> Repo.one!()
  end

  @doc """
  Gets a single ozfa.

  Raises `Ecto.NoResultsError` if the Ozfa does not exist.

  ## Examples

      iex> get_ozfa!(123)
      %Ozfa{}

      iex> get_ozfa!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ozfa!(id), do: Repo.get!(Ozfa, id)

  def get_ozfa(id), do: Repo.get(Ozfa, id)

  def get_ozfa_by(get_by) do
    Repo.get_by(Ozfa, get_by)
  end

  @doc """
  Creates a ozfa.

  ## Examples

      iex> create_ozfa(%{field: value})
      {:ok, %Ozfa{}}

      iex> create_ozfa(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ozfa(%User{} = user, attrs \\ %{}) do
    Repo.transaction(fn ->
      %Ozfa{}
      |> Ozfa.changeset(attrs)
      |> Repo.insert!()
      |> add_user_to_ozfa!(user, %{owned: true})
    end)
  end

  def add_user_to_ozfa!(%Ozfa{} = ozfa, %User{} = user, attrs \\ %{}) do
    %UserOzfa{}
    |> UserOzfa.changeset(Map.merge(%{user_id: user.id, ozfa_id: ozfa.id}, attrs))
    |> Repo.insert!()

    ozfa
  end

  def find_user_ozfa(ozfa, user) do
    Repo.get_by(UserOzfa, ozfa_id: ozfa.id, user_id: user.id)
  end

  def create_user_ozfa(%Ozfa{} = ozfa, %User{} = user, attrs \\ %{}) do
    %UserOzfa{}
    |> UserOzfa.changeset(Map.merge(%{user_id: user.id, ozfa_id: ozfa.id}, attrs))
    |> Repo.insert()
  end

  def find_or_create_user_ozfa(%Ozfa{} = ozfa, %User{} = user) do
    if user_ozfa = find_user_ozfa(ozfa, user) do
      {:ok, user_ozfa}
    else
      create_user_ozfa(ozfa, user)
    end
  end

  def update_user_ozfa(user_ozfa, attrs) do
    user_ozfa
    |> UserOzfa.changeset(attrs)
    |> Repo.update()
  end

  def delete_user_ozfa(%Ozfa{} = ozfa, %User{} = user) do
    if user_ozfa = find_user_ozfa(ozfa, user) do
      Repo.delete!(user_ozfa)
    end

    ozfa
  end

  def update_or_create_user_ozfa(%Ozfa{} = ozfa, %User{} = user, attrs \\ %{}) do
    case find_user_ozfa(ozfa, user) do
      nil -> create_user_ozfa(ozfa, user, attrs)
      user_ozfa -> update_user_ozfa(user_ozfa, attrs)
    end
  end

  @doc """
  Updates a ozfa.

  ## Examples

      iex> update_ozfa(ozfa, %{field: new_value})
      {:ok, %Ozfa{}}

      iex> update_ozfa(ozfa, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ozfa(%Ozfa{} = ozfa, attrs) do
    ozfa
    |> Ozfa.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ozfa.

  ## Examples

      iex> delete_ozfa(ozfa)
      {:ok, %Ozfa{}}

      iex> delete_ozfa(ozfa)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ozfa(%Ozfa{} = ozfa) do
    Repo.delete(ozfa)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ozfa changes.

  ## Examples

      iex> change_ozfa(ozfa)
      %Ecto.Changeset{data: %Ozfa{}}

  """
  def change_ozfa(%Ozfa{} = ozfa, attrs \\ %{}) do
    Ozfa.changeset(ozfa, attrs)
  end

  def save_ozfa(ozfa, user, params) do
    if ozfa.id do
      update_ozfa(ozfa, params)
    else
      create_ozfa(user, params)
    end
  end

  def save_image(ozfa, user, upload_entry) do
    save_ozfa(ozfa, user, %{
      type: "image",
      url: upload_entry.file_name,
      hash: upload_entry.hash,
      width: upload_entry.width,
      height: upload_entry.height
    })
  end
end
