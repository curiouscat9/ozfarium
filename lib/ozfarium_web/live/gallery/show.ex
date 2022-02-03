defmodule OzfariumWeb.Live.Gallery.Show do
  use OzfariumWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  def tag_rating(ozfa, tag) do
    ozfa.user_ozfa_tags
    |> Enum.find(&(&1.tag_id == tag.id))
    |> case do
      nil -> 0
      user_ozfa_tag -> user_ozfa_tag.rating
    end
  end

  def star(%{rating: rating, position: position, ozfa_id: ozfa_id, tag_id: tag_id} = assigns) do
    cond do
      position == -1 && rating < 0 ->
        ~H"""
          <.icon name="eye_off" class="h-14 w-14 md:h-10 md:w-10 text-red-500 hover:text-red-700 opacity-80 drop-shadow-md" />
        """

      position == -1 && rating == 0 ->
        ~H"""
        <div phx-click={JS.push("rate-tag", value: %{ozfa_id: ozfa_id, tag_id: tag_id, rating: -1})}>
          <.icon name="eye" class="h-14 w-14 md:h-10 md:w-10 text-gray-500 hover:text-gray-700 opacity-80 drop-shadow-md" />
        </div>
        """

      position == -1 && rating > 0 ->
        ~H"""
        <div phx-click={JS.push("rate-tag", value: %{ozfa_id: ozfa_id, tag_id: tag_id, rating: 0})}>
          <.icon name="trash" class="h-14 w-14 md:h-10 md:w-10 text-gray-500 hover:text-gray-700 opacity-80 drop-shadow-md" />
        </div>
        """

      position > 0 && rating >= position ->
        ~H"""
        <div class="relative" phx-click={JS.push("rate-tag", value: %{ozfa_id: ozfa_id, tag_id: tag_id, rating: position})}>
          <.icon name="sparkles" type="solid" class="h-14 w-14 md:h-10 md:w-10 text-purple-500 hover:text-purple-700 drop-shadow-md" />
        </div>
        """

      true ->
        ~H"""
        <div class="relative" phx-click={JS.push("rate-tag", value: %{ozfa_id: ozfa_id, tag_id: tag_id, rating: position})}>
        <.icon name="sparkles" class="h-14 w-14 md:h-10 md:w-10 text-gray-500 hover:text-gray-700 drop-shadow-md" />
        </div>
        """
    end
  end
end
