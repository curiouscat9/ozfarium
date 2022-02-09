defmodule OzfariumWeb.Live.Navbar do
  use OzfariumWeb, :live_component

  def sub_links(assigns) do
    ~H"""
      <!-- Current: "bg-gray-300 text-white", Default: "text-gray-300 hover:bg-gray-700 hover:text-white"
      <a href="#" class="bg-gray-300 text-white px-3 py-2 rounded-md text-sm font-medium">Something</a>
      -->
        <a href="/?listed=my_liked" class="text-gray-700 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium">
        Мои озфа
        <.icon name="heart" type="solid" class="h-6 w-6 inline opacity-70 text-rose-500 hover:text-rose-700 drop-shadow-md cursor-pointer" />
      </a>
    """
  end
end
