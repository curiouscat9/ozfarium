defmodule OzfariumWeb.Live.Gallery.Pagination do
  use OzfariumWeb, :live_component

  @doc """
    Returns pagination array

    ## Examples

    [[1]   2    3    4    5    6   7    8]\n
    [[1]   2    3    4    5    6   7    ...   99]\n
    [ 1   [2]   3    4    5    6   7    ...   99]\n
    [ 1    2   [3]   4    5    6   7    ...   99]\n
    [ 1    2    3   [4]   5    6   7    ...   99]\n
    [ 1    2    3    4   [5]   6   7    ...   99]\n
    [ 1   ...   4    5   [6]   7   8    ...   99]\n
    [ 1   ...   5    6   [7]   8   9    ...   99]\n
    [ 1   ...   92   93  [94]  95  96   ...   99]\n
    [ 1   ...   93   94  [95]  96  97   98    99]\n
    [ 1   ...   93   94   95  [96] 97   98    99]\n
    [ 1   ...   93   94   95   96 [97]  98    99]\n
    [ 1   ...   93   94   95   96  97  [98]   99]\n
    [ 1   ...   93   94   95   96  97   98   [99]]\n
  """

  def show_pages(page_count, current_page), do: show_pages(page_count, current_page, 4)

  def show_pages(page_count, current_page, side_width) when side_width < 3 do
    show_pages_small(page_count, current_page, side_width * 2 + 1)
  end

  def show_pages(page_count, current_page, side_width) do
    width = side_width * 2 + 1
    max_third = page_count - width + 3

    if page_count <= width do
      Enum.to_list(1..page_count)
    else
      second = if current_page > side_width + 1, do: nil, else: 2
      pre_last = if current_page < page_count - side_width, do: nil, else: page_count - 1
      middle_start = current_page - (side_width - 2)
      middle_start = if middle_start < 3, do: 3, else: middle_start
      middle_start = if middle_start > max_third, do: max_third, else: middle_start
      middle_end = middle_start + (side_width - 2) * 2
      middle_end = if middle_end > page_count - 2, do: page_count - 2, else: middle_end

      [1, second] ++ Enum.to_list(middle_start..middle_end) ++ [pre_last, page_count]
    end
  end

  def show_pages_small(page_count, current_page, width) do
    max_start = page_count - width + 1

    if page_count <= width do
      Enum.to_list(1..page_count)
    else
      start_page = current_page - div(width - 1, 2)
      start_page = if start_page < 1, do: 1, else: start_page
      start_page = if start_page > max_start, do: max_start, else: start_page
      end_page = start_page + width - 1
      end_page = if end_page > page_count, do: page_count, else: end_page

      Enum.to_list(start_page..end_page)
    end
  end
end
