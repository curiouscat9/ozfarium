defmodule Ozfarium.Gallery do
  @moduledoc """
  The Gallery context.
  """

  import Ecto.Query, warn: false
  alias Ozfarium.Repo

  alias Ozfarium.Gallery.Ozfa

  @doc """
  Returns the list of ozfa ids.

  ## Examples

      iex> list_ozfas()
      [1, ...]

  """
  def list_ozfas(params \\ %{}) do
    ozfas =
      from(o in Ozfa, select: o.id, order_by: o.id)
      |> Repo.all()

    if params[:even] == 1 do
      ozfas |> Enum.filter(&(rem(&1, 2) == 0))
    else
      ozfas
    end
  end

  def preload_missing_ozfas(preloaded_ozfas, ids) do
    case ids -- Map.keys(preloaded_ozfas) do
      [] -> preloaded_ozfas
      preload_ids -> Map.merge(preloaded_ozfas, preload_ozfas(preload_ids))
    end
  end

  def preload_ozfas(ids) do
    from(o in Ozfa, where: o.id in ^ids, select: {o.id, o})
    |> Repo.all()
    |> Map.new()
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

  @doc """
  Creates a ozfa.

  ## Examples

      iex> create_ozfa(%{field: value})
      {:ok, %Ozfa{}}

      iex> create_ozfa(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ozfa(attrs \\ %{}) do
    %Ozfa{}
    |> Ozfa.changeset(attrs)
    |> Repo.insert()
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

  def save_ozfa(ozfa, params) do
    if ozfa.id do
      update_ozfa(ozfa, params)
    else
      create_ozfa(params)
    end
  end
end
