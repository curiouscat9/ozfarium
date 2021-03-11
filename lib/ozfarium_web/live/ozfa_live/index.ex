defmodule OzfariumWeb.OzfaLive.Index do
  use OzfariumWeb, :live_view

  alias Ozfarium.Gallery
  alias Ozfarium.Gallery.Ozfa

  @default_filters [
    {:page, 1, :integer},
    {:per_page, 24, :integer},
    {:even, 0, :boolean},
    {:q, "", :string}
  ]

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
  def handle_event("load-more", _, socket) do
    {:noreply,
     assign(socket,
       page: socket.assigns.page + 1,
       infinite_pages: socket.assigns.infinite_pages + 1
     )
     |> assign_paginated_ozfas()
     |> push_patch_filter_uri()}
  end

  @impl true
  def handle_event("filter", %{"_target" => ["filter", _], "filter" => params}, socket) do
    IO.inspect(params)

    {:noreply,
     assign_filter_params(socket, Map.merge(params, %{"page" => "1"}))
     |> assign_ozfas()
     |> assign_paginated_ozfas()
     |> push_patch_filter_uri()}
  end

  defp assign_filter_params(socket, params, opts \\ %{}) do
    assign(
      socket,
      @default_filters
      |> Enum.reduce(%{}, fn {k, default, type}, acc ->
        if params[Atom.to_string(k)] do
          Map.put(acc, k, parse_param(params[Atom.to_string(k)], default, type))
        else
          if opts[:with_default], do: Map.put(acc, k, default), else: acc
        end
      end)
      |> Map.merge(%{infinite_pages: 1})
    )
  end

  defp assign_ozfas(socket) do
    assign(socket,
      ozfas: Gallery.list_ozfas(Map.take(socket.assigns, default_filters_keys()))
    )
  end

  defp assign_paginated_ozfas(socket) do
    to = socket.assigns.page * socket.assigns.per_page - 1
    from = to - socket.assigns.per_page * socket.assigns.infinite_pages + 1
    page_count = ceil(Enum.count(socket.assigns.ozfas) / socket.assigns.per_page)

    assign(socket,
      paginated_ozfas: Enum.slice(socket.assigns.ozfas, from..to),
      total_count: Enum.count(socket.assigns.ozfas),
      page_count: if(page_count == 0, do: 1, else: page_count)
    )
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
    |> Enum.reduce(URI.decode_query(assigns.uri.query || ""), fn {k, default, _}, uri_params ->
      uri_params = Map.delete(uri_params, Atom.to_string(k))

      if assigns[k] && assigns[k] != default do
        Map.put(uri_params, k, assigns[k])
      else
        uri_params
      end
    end)
  end

  defp parse_param(str, default, type) do
    case type do
      :integer -> parse_int(str, default)
      :boolean -> parse_bool(str, default)
      :string -> str || default
    end
  end

  defp parse_int(str, default) do
    case Integer.parse(str || "") do
      {int, _} -> int
      :error -> default
    end
  end

  defp parse_bool(str, default) do
    case str do
      "1" -> 1
      "0" -> 0
      "true" -> 1
      "false" -> 0
      _ -> default
    end
  end

  defp default_filters_keys do
    Enum.map(@default_filters, &elem(&1, 0))
  end
end
