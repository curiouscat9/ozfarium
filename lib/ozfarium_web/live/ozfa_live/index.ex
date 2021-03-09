defmodule OzfariumWeb.OzfaLive.Index do
  use OzfariumWeb, :live_view

  alias Ozfarium.Gallery
  alias Ozfarium.Gallery.Ozfa

  @impl true
  def mount(_params, _session, socket) do
    ozfas = Gallery.list_ozfas()
    {:ok, assign(socket, all_ozfas: ozfas, page: 1, per_page: 15, ozfas: paginate(ozfas, 1, 15))}
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
  def handle_event("page", %{"page" => page}, socket) do
    {page, _} = Integer.parse(page)

    {:noreply,
     assign(socket,
       page: page,
       ozfas: paginate(socket.assigns.all_ozfas, page, socket.assigns.per_page)
     )}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ozfa = Gallery.get_ozfa!(id)
    {:ok, _} = Gallery.delete_ozfa(ozfa)
    ozfas = Gallery.list_ozfas()

    {:noreply,
     assign(socket,
       all_ozfas: ozfas,
       ozfas: paginate(ozfas, socket.assigns.page, socket.assigns.per_page)
     )}
  end

  defp paginate(ozfas, page, per_page) do
    to = page * per_page - 1
    from = to - per_page + 1

    ozfas |> Enum.slice(from..to)
  end
end
