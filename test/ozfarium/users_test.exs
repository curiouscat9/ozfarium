defmodule Ozfarium.UsersTest do
  use Ozfarium.DataCase

  alias Ozfarium.Users

  describe "user_ozfa_tags" do
    alias Ozfarium.Users.UserOzfaTag

    import Ozfarium.UsersFixtures

    @invalid_attrs %{rating: nil}

    test "list_user_ozfa_tags/0 returns all user_ozfa_tags" do
      user_ozfa_tag = user_ozfa_tag_fixture()
      assert Users.list_user_ozfa_tags() == [user_ozfa_tag]
    end

    test "get_user_ozfa_tag!/1 returns the user_ozfa_tag with given id" do
      user_ozfa_tag = user_ozfa_tag_fixture()
      assert Users.get_user_ozfa_tag!(user_ozfa_tag.id) == user_ozfa_tag
    end

    test "create_user_ozfa_tag/1 with valid data creates a user_ozfa_tag" do
      valid_attrs = %{rating: 42}

      assert {:ok, %UserOzfaTag{} = user_ozfa_tag} = Users.create_user_ozfa_tag(valid_attrs)
      assert user_ozfa_tag.rating == 42
    end

    test "create_user_ozfa_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user_ozfa_tag(@invalid_attrs)
    end

    test "update_user_ozfa_tag/2 with valid data updates the user_ozfa_tag" do
      user_ozfa_tag = user_ozfa_tag_fixture()
      update_attrs = %{rating: 43}

      assert {:ok, %UserOzfaTag{} = user_ozfa_tag} = Users.update_user_ozfa_tag(user_ozfa_tag, update_attrs)
      assert user_ozfa_tag.rating == 43
    end

    test "update_user_ozfa_tag/2 with invalid data returns error changeset" do
      user_ozfa_tag = user_ozfa_tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user_ozfa_tag(user_ozfa_tag, @invalid_attrs)
      assert user_ozfa_tag == Users.get_user_ozfa_tag!(user_ozfa_tag.id)
    end

    test "delete_user_ozfa_tag/1 deletes the user_ozfa_tag" do
      user_ozfa_tag = user_ozfa_tag_fixture()
      assert {:ok, %UserOzfaTag{}} = Users.delete_user_ozfa_tag(user_ozfa_tag)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user_ozfa_tag!(user_ozfa_tag.id) end
    end

    test "change_user_ozfa_tag/1 returns a user_ozfa_tag changeset" do
      user_ozfa_tag = user_ozfa_tag_fixture()
      assert %Ecto.Changeset{} = Users.change_user_ozfa_tag(user_ozfa_tag)
    end
  end
end
