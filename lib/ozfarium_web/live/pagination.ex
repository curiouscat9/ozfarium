defmodule OzfariumWeb.Pagination do
  use OzfariumWeb, :live_component

  @side_width 5

  # <  [1]   2    3    4    5    6   7    8   >
  # <  [1]   2    3    4    5    6   7    ...   99   >
  # <   1   [2]   3    4    5    6   7    ...   99   >
  # <   1    2   [3]   4    5    6   7    ...   99   >
  # <   1    2    3   [4]   5    6   7    ...   99   >
  # <   1    2    3    4   [5]   6   7    ...   99   >
  # <   1   ...   4    5   [6]   7   8    ...   99   >
  # <   1   ...   5    6   [7]   8   9    ...   99   >
  # <   1   ...   92   93  [94]  95  96   ...   99   >
  # <   1   ...   93   94  [95]  96  97   98    99   >
  # <   1   ...   93   94   95  [96] 97   98    99   >
  # <   1   ...   93   94   95   96 [97]  98    99   >
  # <   1   ...   93   94   95   96  97  [98]   99   >
  # <   1   ...   93   94   95   96  97   98   [99]  >

  def shown_pages(page_count, current_page) do
    width = @side_width * 2 + 1
    max_third = page_count - width + 2

    if page_count <= width do
      1..page_count
    else
      second = if current_page > @side_width + 1, do: nil, else: 2
      pre_last = if current_page < page_count - @side_width, do: nil, else: page_count - 1
      middle_start = current_page - (@side_width - 2)
      middle_start = if middle_start < 3, do: 3, else: middle_start
      middle_start = if middle_start > max_third, do: max_third, else: middle_start
      middle_end = middle_start + (@side_width - 2) * 2
      middle_end = if middle_end > page_count - 2, do: page_count - 2, else: middle_end

      [1, second] ++ Enum.to_list(middle_start..middle_end) ++ [pre_last, page_count]
    end
  end
end
