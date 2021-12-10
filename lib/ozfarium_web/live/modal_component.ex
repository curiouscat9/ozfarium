defmodule OzfariumWeb.ModalComponent do
  use OzfariumWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} phx-hook="OpenModal" class="fixed inset-0 w-full h-full z-20 bg-black bg-opacity-50 duration-300 overflow-y-auto"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target={"##{@id}"}
      phx-page-loading>
      <div class={"relative opacity-100 #{@size_classes}"}>
        <div class="relative bg-white shadow-lg rounded-md text-gray-900 z-20">
          <span phx-click="close" phx-target={@myself} class="absolute top-0 right-0 p-1 cursor-pointer text-gray-400 hover:text-gray-700">
            <span class="sr-only">Close</span><%= icon_close() %>
          </span>

          <%= live_component @component, @opts %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    send(self(), {:close_modal, %{}})
    {:noreply, socket}
  end
end
