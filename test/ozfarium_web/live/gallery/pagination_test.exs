defmodule OzfariumWeb.Live.Gallery.PaginationTest do
  use Ozfarium.DataCase

  alias OzfariumWeb.Live.Gallery.Pagination

  describe "#show_pages default width 4" do
    test "render one page" do
      assert Pagination.show_pages(1, 1) == [1]
    end

    test "render 5 pages" do
      assert Pagination.show_pages(5, 1) == [1, 2, 3, 4, 5]
      assert Pagination.show_pages(5, 3) == [1, 2, 3, 4, 5]
      assert Pagination.show_pages(5, 5) == [1, 2, 3, 4, 5]
    end

    test "render 9 pages" do
      assert Pagination.show_pages(9, 1) == [1, 2, 3, 4, 5, 6, 7, 8, 9]
      assert Pagination.show_pages(9, 3) == [1, 2, 3, 4, 5, 6, 7, 8, 9]
      assert Pagination.show_pages(9, 9) == [1, 2, 3, 4, 5, 6, 7, 8, 9]
    end

    test "render 99 pages" do
      assert Pagination.show_pages(99, 1) == [1, 2, 3, 4, 5, 6, 7, nil, 99]
      assert Pagination.show_pages(99, 2) == [1, 2, 3, 4, 5, 6, 7, nil, 99]
      assert Pagination.show_pages(99, 3) == [1, 2, 3, 4, 5, 6, 7, nil, 99]
      assert Pagination.show_pages(99, 4) == [1, 2, 3, 4, 5, 6, 7, nil, 99]
      assert Pagination.show_pages(99, 5) == [1, 2, 3, 4, 5, 6, 7, nil, 99]
      assert Pagination.show_pages(99, 6) == [1, nil, 4, 5, 6, 7, 8, nil, 99]
      assert Pagination.show_pages(99, 7) == [1, nil, 5, 6, 7, 8, 9, nil, 99]
      assert Pagination.show_pages(99, 33) == [1, nil, 31, 32, 33, 34, 35, nil, 99]
      assert Pagination.show_pages(99, 94) == [1, nil, 92, 93, 94, 95, 96, nil, 99]
      assert Pagination.show_pages(99, 95) == [1, nil, 93, 94, 95, 96, 97, 98, 99]
      assert Pagination.show_pages(99, 96) == [1, nil, 93, 94, 95, 96, 97, 98, 99]
      assert Pagination.show_pages(99, 97) == [1, nil, 93, 94, 95, 96, 97, 98, 99]
      assert Pagination.show_pages(99, 98) == [1, nil, 93, 94, 95, 96, 97, 98, 99]
      assert Pagination.show_pages(99, 99) == [1, nil, 93, 94, 95, 96, 97, 98, 99]
    end
  end

  describe "#show_pages width 5" do
    test "render one page" do
      assert Pagination.show_pages(1, 1, 5) == [1]
    end

    test "render 5 pages" do
      assert Pagination.show_pages(5, 1, 5) == [1, 2, 3, 4, 5]
      assert Pagination.show_pages(5, 3, 5) == [1, 2, 3, 4, 5]
      assert Pagination.show_pages(5, 5, 5) == [1, 2, 3, 4, 5]
    end

    test "render 11 pages" do
      assert Pagination.show_pages(11, 1, 5) == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
      assert Pagination.show_pages(11, 3, 5) == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
      assert Pagination.show_pages(11, 11, 5) == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    end

    test "render 99 pages" do
      assert Pagination.show_pages(99, 1, 5) == [1, 2, 3, 4, 5, 6, 7, 8, 9, nil, 99]
      assert Pagination.show_pages(99, 2, 5) == [1, 2, 3, 4, 5, 6, 7, 8, 9, nil, 99]
      assert Pagination.show_pages(99, 3, 5) == [1, 2, 3, 4, 5, 6, 7, 8, 9, nil, 99]
      assert Pagination.show_pages(99, 5, 5) == [1, 2, 3, 4, 5, 6, 7, 8, 9, nil, 99]
      assert Pagination.show_pages(99, 6, 5) == [1, 2, 3, 4, 5, 6, 7, 8, 9, nil, 99]
      assert Pagination.show_pages(99, 7, 5) == [1, nil, 4, 5, 6, 7, 8, 9, 10, nil, 99]
      assert Pagination.show_pages(99, 8, 5) == [1, nil, 5, 6, 7, 8, 9, 10, 11, nil, 99]
      assert Pagination.show_pages(99, 33, 5) == [1, nil, 30, 31, 32, 33, 34, 35, 36, nil, 99]
      assert Pagination.show_pages(99, 92, 5) == [1, nil, 89, 90, 91, 92, 93, 94, 95, nil, 99]
      assert Pagination.show_pages(99, 93, 5) == [1, nil, 90, 91, 92, 93, 94, 95, 96, nil, 99]
      assert Pagination.show_pages(99, 94, 5) == [1, nil, 91, 92, 93, 94, 95, 96, 97, 98, 99]
      assert Pagination.show_pages(99, 95, 5) == [1, nil, 91, 92, 93, 94, 95, 96, 97, 98, 99]
      assert Pagination.show_pages(99, 96, 5) == [1, nil, 91, 92, 93, 94, 95, 96, 97, 98, 99]
      assert Pagination.show_pages(99, 97, 5) == [1, nil, 91, 92, 93, 94, 95, 96, 97, 98, 99]
      assert Pagination.show_pages(99, 98, 5) == [1, nil, 91, 92, 93, 94, 95, 96, 97, 98, 99]
      assert Pagination.show_pages(99, 99, 5) == [1, nil, 91, 92, 93, 94, 95, 96, 97, 98, 99]
    end
  end

  describe "#show_pages width 2" do
    test "render one page" do
      assert Pagination.show_pages(1, 1, 2) == [1]
    end

    test "render 5 pages" do
      assert Pagination.show_pages(5, 1, 2) == [1, 2, 3, 4, 5]
      assert Pagination.show_pages(5, 3, 2) == [1, 2, 3, 4, 5]
      assert Pagination.show_pages(5, 5, 2) == [1, 2, 3, 4, 5]
    end

    test "render 99 pages" do
      assert Pagination.show_pages(99, 1, 2) == [1, 2, 3, 4, 5]
      assert Pagination.show_pages(99, 2, 2) == [1, 2, 3, 4, 5]
      assert Pagination.show_pages(99, 3, 2) == [1, 2, 3, 4, 5]
      assert Pagination.show_pages(99, 4, 2) == [2, 3, 4, 5, 6]
      assert Pagination.show_pages(99, 5, 2) == [3, 4, 5, 6, 7]
      assert Pagination.show_pages(99, 33, 2) == [31, 32, 33, 34, 35]
      assert Pagination.show_pages(99, 96, 2) == [94, 95, 96, 97, 98]
      assert Pagination.show_pages(99, 97, 2) == [95, 96, 97, 98, 99]
      assert Pagination.show_pages(99, 98, 2) == [95, 96, 97, 98, 99]
      assert Pagination.show_pages(99, 99, 2) == [95, 96, 97, 98, 99]
    end
  end

  describe "#show_pages width 1" do
    test "render one page" do
      assert Pagination.show_pages(1, 1, 1) == [1]
    end

    test "render 3 pages" do
      assert Pagination.show_pages(3, 1, 1) == [1, 2, 3]
      assert Pagination.show_pages(3, 3, 1) == [1, 2, 3]
      assert Pagination.show_pages(3, 5, 1) == [1, 2, 3]
    end

    test "render 99 pages" do
      assert Pagination.show_pages(99, 1, 1) == [1, 2, 3]
      assert Pagination.show_pages(99, 2, 1) == [1, 2, 3]
      assert Pagination.show_pages(99, 3, 1) == [2, 3, 4]
      assert Pagination.show_pages(99, 4, 1) == [3, 4, 5]
      assert Pagination.show_pages(99, 33, 1) == [32, 33, 34]
      assert Pagination.show_pages(99, 96, 1) == [95, 96, 97]
      assert Pagination.show_pages(99, 97, 1) == [96, 97, 98]
      assert Pagination.show_pages(99, 98, 1) == [97, 98, 99]
      assert Pagination.show_pages(99, 99, 1) == [97, 98, 99]
    end
  end
end
