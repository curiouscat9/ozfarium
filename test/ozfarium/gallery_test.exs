defmodule Ozfarium.GalleryTest do
  use Ozfarium.DataCase

  alias Ozfarium.Gallery

  describe "ozfas" do
    alias Ozfarium.Gallery.Ozfa

    @valid_attrs %{content: "some content", type: "some type", url: "some url"}
    @update_attrs %{content: "some updated content", type: "some updated type", url: "some updated url"}
    @invalid_attrs %{content: nil, type: nil, url: nil}

    def ozfa_fixture(attrs \\ %{}) do
      {:ok, ozfa} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Gallery.create_ozfa()

      ozfa
    end

    test "list_ozfas/0 returns all ozfas" do
      ozfa = ozfa_fixture()
      assert Gallery.list_ozfas() == [ozfa]
    end

    test "get_ozfa!/1 returns the ozfa with given id" do
      ozfa = ozfa_fixture()
      assert Gallery.get_ozfa!(ozfa.id) == ozfa
    end

    test "create_ozfa/1 with valid data creates a ozfa" do
      assert {:ok, %Ozfa{} = ozfa} = Gallery.create_ozfa(@valid_attrs)
      assert ozfa.content == "some content"
      assert ozfa.type == "some type"
      assert ozfa.url == "some url"
    end

    test "create_ozfa/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gallery.create_ozfa(@invalid_attrs)
    end

    test "update_ozfa/2 with valid data updates the ozfa" do
      ozfa = ozfa_fixture()
      assert {:ok, %Ozfa{} = ozfa} = Gallery.update_ozfa(ozfa, @update_attrs)
      assert ozfa.content == "some updated content"
      assert ozfa.type == "some updated type"
      assert ozfa.url == "some updated url"
    end

    test "update_ozfa/2 with invalid data returns error changeset" do
      ozfa = ozfa_fixture()
      assert {:error, %Ecto.Changeset{}} = Gallery.update_ozfa(ozfa, @invalid_attrs)
      assert ozfa == Gallery.get_ozfa!(ozfa.id)
    end

    test "delete_ozfa/1 deletes the ozfa" do
      ozfa = ozfa_fixture()
      assert {:ok, %Ozfa{}} = Gallery.delete_ozfa(ozfa)
      assert_raise Ecto.NoResultsError, fn -> Gallery.get_ozfa!(ozfa.id) end
    end

    test "change_ozfa/1 returns a ozfa changeset" do
      ozfa = ozfa_fixture()
      assert %Ecto.Changeset{} = Gallery.change_ozfa(ozfa)
    end
  end
end
