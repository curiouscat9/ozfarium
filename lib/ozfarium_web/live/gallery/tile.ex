defmodule OzfariumWeb.Live.Gallery.Tile do
  use OzfariumWeb, :live_component

  alias Ozfarium.Gallery

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def preload(list_of_assigns) do
    list_of_ids = Enum.map(list_of_assigns, & &1.id)

    ozfas = Gallery.preload_ozfas(list_of_ids)

    Enum.map(list_of_assigns, fn assigns ->
      Map.put(assigns, :ozfa, ozfas[assigns.id])
    end)
  end
end
