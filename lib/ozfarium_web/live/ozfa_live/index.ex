defmodule OzfariumWeb.OzfaLive.Index do
  use OzfariumWeb, :live_view

  alias Ozfarium.Gallery
  alias Ozfarium.Gallery.Ozfa

  @default_filters %{
    page: 1,
    per_page: 15,
    even: 0
  }

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     assign_filter_params(socket, params, with_default: true)
     |> assign_ozfas()
     |> assign_paginated_ozfas()}
  end

  @impl true
  def handle_params(params, uri, socket) do
    socket = assign(socket, :uri, URI.parse(uri))
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
    ozfas = Gallery.list_ozfas()

    {:noreply,
     assign(socket, ozfas: ozfas)
     |> assign_paginated_ozfas()}
  end

  @impl true
  def handle_event("page", params, socket) do
    {:noreply,
     assign_filter_params(socket, params)
     |> assign_paginated_ozfas()
     |> push_patch_filter_uri()}
  end

  @impl true
  def handle_event("filter", params, socket) do
    {:noreply,
     assign_filter_params(socket, Map.merge(params, %{"page" => "1"}))
     |> assign_ozfas()
     |> assign_paginated_ozfas()
     |> push_patch_filter_uri()}
  end

  defp assign_filter_params(socket, params, opts \\ %{}) do
    def_filters =
      @default_filters |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end) |> Map.new()

    assign(
      socket,
      def_filters
      |> Enum.reduce(%{}, fn {k, _}, acc ->
        if params[k] do
          Map.put(acc, String.to_atom(k), parse_int(params[k], def_filters[k]))
        else
          if opts[:with_default] do
            Map.put(acc, String.to_atom(k), def_filters[k])
          else
            acc
          end
        end
      end)
    )
  end

  defp assign_ozfas(socket) do
    assign(socket, ozfas: Gallery.list_ozfas(Map.take(socket.assigns, Map.keys(@default_filters))))
  end

  defp assign_paginated_ozfas(socket) do
    to = socket.assigns.page * socket.assigns.per_page - 1
    from = to - socket.assigns.per_page + 1

    assign(socket, paginated_ozfas: Enum.slice(socket.assigns.ozfas, from..to))
  end

  defp push_patch_filter_uri(socket) do
    push_patch(socket,
      to: build_path(socket.assigns.uri.path, filtered_uri_params(socket.assigns))
    )
  end

  defp build_path(path, uri_params) when map_size(uri_params) == 0, do: path

  defp build_path(path, uri_params) do
    path <> "?" <> URI.encode_query(uri_params)
  end

  defp filtered_uri_params(assigns) do
    @default_filters
    |> Map.keys()
    |> Enum.reduce(get_current_uri_params(assigns.uri), fn key, current_params ->
      assigned = Map.get(assigns, key)

      if assigned && assigned != Map.get(@default_filters, key) do
        Map.put(current_params, key, assigned)
      else
        Map.delete(current_params, key)
      end
    end)
  end

  defp get_current_uri_params(uri) do
    valid_keys = @default_filters |> Map.keys() |> Enum.map(fn k -> Atom.to_string(k) end)

    URI.decode_query(uri.query || "")
    |> Enum.reduce(%{}, fn {k, v}, acc ->
      Map.put(acc, if(Enum.member?(valid_keys, k), do: String.to_atom(k), else: k), v)
    end)
  end

  defp parse_int(str, default) do
    case Integer.parse(str || "") do
      {int, _} -> int
      :error -> default
    end
  end
end
