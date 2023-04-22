defmodule OzfariumWeb.Live.Gallery.Show do
  use OzfariumWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  def show_controls do
    JS.remove_class("hidden", to: "#view-ozfa-controls")
    |> JS.add_class("hidden", to: "#view-ozfa-controls-show")
    |> JS.add_class("hidden", to: "#view-ozfa-basic-controls")
    |> JS.remove_class("hidden", to: "#view-ozfa-controls-hide")
  end

  def hide_controls do
    JS.add_class("hidden", to: "#view-ozfa-controls")
    |> JS.remove_class("hidden", to: "#view-ozfa-controls-show")
    |> JS.remove_class("hidden", to: "#view-ozfa-basic-controls")
    |> JS.add_class("hidden", to: "#view-ozfa-controls-hide")
  end


def show_comments do
  JS.remove_class("hidden", to: "#view-ozfa-comments")
  |> JS.add_class("hidden", to: "#view-ozfa-comments-show")
  |> JS.remove_class("hidden", to: "#view-ozfa-comments-hide")
  |> JS.dispatch("reloadCommentsWidget")
end

  def hide_comments do
    JS.add_class("hidden", to: "#view-ozfa-comments")
    |> JS.remove_class("hidden", to: "#view-ozfa-comments-show")
    |> JS.add_class("hidden", to: "#view-ozfa-comments-hide")
  end

  def navigate_left do
    hide_controls()
    |> JS.push("nav-prev")
    |> JS.dispatch("reloadCommentsWidget")

  end

  def navigate_right do
    hide_controls()
    |> JS.push("nav-next")
    |> JS.dispatch("reloadCommentsWidget")
  end

  def tag_rating(ozfa, tag) do
    ozfa.user_ozfa_tags
    |> Enum.find(&(&1.tag_id == tag.id))
    |> case do
      nil -> 0
      user_ozfa_tag -> user_ozfa_tag.rating
    end
  end

  def preload_image(%{ozfa: %{type: "image"} = ozfa} = assigns) do
    ~H"""
    <div class="h-0 w-0 invisible hidden lg:block lg:visible">
      <div class="h-0 w-0" style={"background-image: url(#{s3_url(ozfa.url)});"}></div>
    </div>
    <div class="h-0 w-0 hidden invisible ts:block ts:visible lg:hidden lg:invisible">
      <div class="h-0 w-0" style={"background-image: url(#{s3_url(ozfa.url, :cover)});"}></div>
    </div>
    """
  end

  def preload_image(assigns) do
    ~H"""
    """
  end

  def star(%{rating: rating, position: position, ozfa_id: ozfa_id, tag_id: tag_id} = assigns) do
    cond do
      position == -1 && rating < 0 ->
        ~H"""
          <.icon name="eye_off" class="h-14 w-14 md:h-8 md:w-8 text-red-500 hover:text-red-700 opacity-80 drop-shadow-md" />
        """

      position == -1 && rating == 0 ->
        ~H"""
        <div phx-click={JS.push("rate-tag", value: %{ozfa_id: ozfa_id, tag_id: tag_id, rating: -1})}>
          <.icon name="eye" class="h-14 w-14 md:h-8 md:w-8 text-gray-500 hover:text-gray-700 opacity-80 drop-shadow-md" />
        </div>
        """

      position == -1 && rating > 0 ->
        ~H"""
        <div phx-click={JS.push("rate-tag", value: %{ozfa_id: ozfa_id, tag_id: tag_id, rating: 0})}>
          <.icon name="trash" class="h-14 w-14 md:h-8 md:w-8 text-gray-500 hover:text-gray-700 opacity-80 drop-shadow-md" />
        </div>
        """

      position > 0 && rating >= position ->
        ~H"""
        <div class="relative" phx-click={JS.push("rate-tag", value: %{ozfa_id: ozfa_id, tag_id: tag_id, rating: position})}>
          <.icon name="sparkles" type="solid" class="h-14 w-14 md:h-8 md:w-8 text-purple-500 hover:text-purple-700 drop-shadow-md" />
        </div>
        """

      true ->
        ~H"""
        <div class="relative" phx-click={JS.push("rate-tag", value: %{ozfa_id: ozfa_id, tag_id: tag_id, rating: position})}>
        <.icon name="sparkles" class="h-14 w-14 md:h-8 md:w-8 text-gray-500 hover:text-gray-700 drop-shadow-md" />
        </div>
        """
    end
  end
end
