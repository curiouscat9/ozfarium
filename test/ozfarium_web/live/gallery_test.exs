defmodule OzfariumWeb.Live.GalleryTest do
  use OzfariumWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Ozfarium.Gallery

  @create_attrs %{content: "some content", type: "some type", url: "some url"}
  @update_attrs %{
    content: "some updated content",
    type: "some updated type",
    url: "some updated url"
  }
  @invalid_attrs %{content: nil, type: nil, url: nil}

  defp fixture(:ozfa) do
    {:ok, ozfa} = Gallery.create_ozfa(@create_attrs)
    ozfa
  end

  defp create_ozfa(_) do
    ozfa = fixture(:ozfa)
    %{ozfa: ozfa}
  end

  describe "Index" do
    setup [:create_ozfa]

    test "lists all ozfas", %{conn: conn, ozfa: ozfa} do
      {:ok, _index_live, html} = live(conn, Routes.ozfa_index_path(conn, :index))

      assert html =~ "Listing Ozfas"
      assert html =~ ozfa.content
    end

    test "saves new ozfa", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.ozfa_index_path(conn, :index))

      assert index_live |> element("a", "New Ozfa") |> render_click() =~
               "New Ozfa"

      assert_patch(index_live, Routes.ozfa_index_path(conn, :new))

      assert index_live
             |> form("#ozfa-form", ozfa: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#ozfa-form", ozfa: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.ozfa_index_path(conn, :index))

      assert html =~ "Ozfa created successfully"
      assert html =~ "some content"
    end

    test "updates ozfa in listing", %{conn: conn, ozfa: ozfa} do
      {:ok, index_live, _html} = live(conn, Routes.ozfa_index_path(conn, :index))

      assert index_live |> element("#ozfa-#{ozfa.id} a", "Edit") |> render_click() =~
               "Edit Ozfa"

      assert_patch(index_live, Routes.ozfa_index_path(conn, :edit, ozfa))

      assert index_live
             |> form("#ozfa-form", ozfa: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#ozfa-form", ozfa: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.ozfa_index_path(conn, :index))

      assert html =~ "Ozfa updated successfully"
      assert html =~ "some updated content"
    end

    test "deletes ozfa in listing", %{conn: conn, ozfa: ozfa} do
      {:ok, index_live, _html} = live(conn, Routes.ozfa_index_path(conn, :index))

      assert index_live |> element("#ozfa-#{ozfa.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#ozfa-#{ozfa.id}")
    end
  end

  describe "Show" do
    setup [:create_ozfa]

    test "displays ozfa", %{conn: conn, ozfa: ozfa} do
      {:ok, _show_live, html} = live(conn, Routes.ozfa_show_path(conn, :show, ozfa))

      assert html =~ "Show Ozfa"
      assert html =~ ozfa.content
    end

    test "updates ozfa within modal", %{conn: conn, ozfa: ozfa} do
      {:ok, show_live, _html} = live(conn, Routes.ozfa_show_path(conn, :show, ozfa))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Ozfa"

      assert_patch(show_live, Routes.ozfa_show_path(conn, :edit, ozfa))

      assert show_live
             |> form("#ozfa-form", ozfa: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#ozfa-form", ozfa: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.ozfa_show_path(conn, :show, ozfa))

      assert html =~ "Ozfa updated successfully"
      assert html =~ "some updated content"
    end
  end
end
