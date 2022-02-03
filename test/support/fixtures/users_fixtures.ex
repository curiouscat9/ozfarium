defmodule Ozfarium.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ozfarium.Users` context.
  """

  @doc """
  Generate a user_ozfa_tag.
  """
  def user_ozfa_tag_fixture(attrs \\ %{}) do
    {:ok, user_ozfa_tag} =
      attrs
      |> Enum.into(%{
        rating: 42
      })
      |> Ozfarium.Users.create_user_ozfa_tag()

    user_ozfa_tag
  end
end
