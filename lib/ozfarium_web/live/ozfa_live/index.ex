defmodule OzfariumWeb.OzfaLive.Index do
  use OzfariumWeb, :live_view

  alias Ozfarium.Gallery
  alias Ozfarium.Gallery.Ozfa

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :ozfas, list_ozfas())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Ozfa")
    |> assign(:ozfa, Gallery.get_ozfa!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Ozfa")
    |> assign(:ozfa, %Ozfa{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Ozfas")
    |> assign(:ozfa, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ozfa = Gallery.get_ozfa!(id)
    {:ok, _} = Gallery.delete_ozfa(ozfa)

    {:noreply, assign(socket, :ozfas, list_ozfas())}
  end

  defp list_ozfas do
    Gallery.list_ozfas()
  end
end
