defmodule OzfariumWeb.ModalComponent do
  use OzfariumWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} phx-hook="OpenModal" class="fixed inset-0 w-full h-full z-20 bg-black bg-opacity-50 duration-300 overflow-y-auto"
      phx-window-keydown="close"
      phx-key="escape"
      phx-page-loading>
      <div class={"relative opacity-100 #{@size_classes}"}>
        <div class="relative bg-white shadow-lg text-gray-900 z-20">
          <span phx-click="close" class="absolute top-0 right-0 z-30 p-1 cursor-pointer opacity-80 text-gray-400 hover:text-gray-700">
            <span class="sr-only">Close</span><.icon name="close" class="h-14 w-14 md:h-10 md:w-10" />
          </span>

          <%= live_component @component, @opts %>
        </div>
      </div>
    </div>
    """
  end
end
