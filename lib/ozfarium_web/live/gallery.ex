defmodule OzfariumWeb.Live.Gallery do
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
     assign(socket, ozfa: nil, preloaded_ozfas: %{}, paginated_ozfas: [])
     |> assign(default_filters())
     |> assign(params_filters(params))
     |> assign_ozfas()
     |> assign_paginated_ozfas()}
  end

  @impl true
  def handle_params(params, uri, socket) do
    socket = assign(socket, :uri, URI.parse(uri))
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Gallery")
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    ozfa = Gallery.get_ozfa!(id)

    socket
    |> assign(page_title: "Ozfa #{id}", ozfa: ozfa)
    |> assign_page_of_current_ozfa()
    |> assign_paginated_ozfas()
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

  @impl true
  def handle_event("delete", %{"id" => id}, %{assigns: assigns} = socket) do
    ozfa = Gallery.get_ozfa!(id)
    {:ok, _} = Gallery.delete_ozfa(ozfa)

    {:noreply,
     assign(socket,
       ozfas: List.delete(assigns.ozfas, ozfa.id),
       preloaded_ozfas: Map.delete(assigns.preloaded_ozfas, ozfa.id),
       ozfa: Gallery.get_ozfa(assigns.next || assigns.prev),
       infinite_pages: 1
     )
     |> assign_page_of_current_ozfa()
     |> assign_paginated_ozfas()
     |> put_flash(:info, "Ozfa was deleted successfully")
     |> push_patch_to_index()}
  end

  @impl true
  def handle_event("page", params, socket) do
    {:noreply,
     assign(socket, params_filters(params))
     |> assign(infinite_pages: 1)
     |> assign_paginated_ozfas()
     |> push_patch_to_index()}
  end

  @impl true
  def handle_event("add-more", _, socket) do
    1..1000
    |> Enum.each(fn _ ->
      Gallery.create_ozfa(%{type: "text", content: "this is ozfa!!"})
    end)

    {:noreply,
     socket
     |> assign(default_filters())
     |> assign_ozfas()
     |> assign_page_of_current_ozfa()
     |> assign_paginated_ozfas()
     |> put_flash(:info, "Added 1000 Ozfas!")
     |> push_patch_to_index()}
  end

  @impl true
  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply,
     assign(socket, page: assigns.page + 1, infinite_pages: assigns.infinite_pages + 1)
     |> assign_paginated_ozfas()
     |> push_patch_to_index()}
  end

  @impl true
  def handle_event("filter", %{"_target" => ["filter", _], "filter" => params}, socket) do
    {:noreply,
     assign(socket, params_filters(params))
     |> assign_ozfas()
     |> assign(page: 1, infinite_pages: 1)
     |> assign_paginated_ozfas()
     |> push_patch_to_index()}
  end

  @impl true
  def handle_info({:close_modal, _}, socket) do
    {:noreply, push_patch_to_index(socket)}
  end

  @impl true
  def handle_info({:updated_ozfa, %{ozfa: ozfa}}, socket) do
    {:noreply,
     socket
     |> assign(ozfa: ozfa, preloaded_ozfas: Map.delete(socket.assigns.preloaded_ozfas, ozfa.id))
     |> assign_paginated_ozfas()
     |> put_flash(:info, "Ozfa updated successfully")
     |> push_patch_to_index()}
  end

  @impl true
  def handle_info({:created_ozfa, %{ozfa: ozfa}}, socket) do
    {:noreply,
     assign(socket, ozfa: ozfa)
     |> assign(default_filters())
     |> assign_ozfas()
     |> assign_page_of_current_ozfa()
     |> assign_paginated_ozfas()
     |> put_flash(:info, "Ozfa created successfully")
     |> push_patch_to_index()}
  end

  defp assign_ozfas(socket) do
    assign(socket,
      ozfas: Gallery.list_ozfas(Map.take(socket.assigns, default_filters_keys()))
    )
  end

  defp assign_page_of_current_ozfa(socket) do
    {page, infinite_pages} = find_page_of_current_ozfa(socket.assigns)

    assign(socket, page: page, infinite_pages: infinite_pages)
  end

  defp assign_paginated_ozfas(%{assigns: assigns} = socket) do
    paginated_ids = paginate_ozfa_ids(assigns)
    preloaded_ozfas = preload_ozfas(assigns.preloaded_ozfas, paginated_ids)
    {prev, next} = find_prev_next(assigns)

    assign(socket,
      preloaded_ozfas: preloaded_ozfas,
      paginated_ozfas: Enum.map(paginated_ids, fn id -> preloaded_ozfas[id] end),
      total_count: Enum.count(assigns.ozfas),
      page_count: div(Enum.count(assigns.ozfas) - 1, assigns.per_page) + 1,
      prev: prev,
      next: next
    )
  end

  defp push_patch_to_index(socket) do
    push_patch(socket, to: index_path(socket))
  end

  defp preload_ozfas(preloaded_ozfas, ids) do
    case ids -- Map.keys(preloaded_ozfas) do
      [] -> preloaded_ozfas
      preload_ids -> Map.merge(preloaded_ozfas, Gallery.preload_ozfas(preload_ids))
    end
  end

  defp paginate_ozfa_ids(%{
         page: page,
         per_page: per_page,
         infinite_pages: infinite_pages,
         ozfas: ozfas
       }) do
    to = page * per_page - 1
    from = to - per_page * infinite_pages + 1
    Enum.slice(ozfas, from..to)
  end

  defp find_prev_next(%{ozfas: ozfas, ozfa: ozfa}) do
    current_index = find_index(ozfas, ozfa)
    prev_index = current_index && current_index > 0 && current_index - 1
    next_index = current_index && current_index + 1

    {at_index(ozfas, prev_index), at_index(ozfas, next_index)}
  end

  defp find_page_of_current_ozfa(%{
         page: page,
         per_page: per_page,
         infinite_pages: infinite_pages,
         ozfas: ozfas,
         ozfa: ozfa
       }) do
    on_page = div(find_index(ozfas, ozfa) || 0, per_page) + 1
    on_shown_page? = on_page >= page - infinite_pages + 1 && on_page <= page

    cond do
      on_shown_page? -> {page, infinite_pages}
      on_page == page + 1 -> {on_page, infinite_pages + 1}
      on_page == page - 1 -> {page, infinite_pages + 1}
      true -> {on_page, 1}
    end
  end

  defp index_path(socket) do
    Routes.gallery_path(socket, :index, filtered_uri_params(socket.assigns))
  end

  defp default_filters do
    @default_filters
    |> Enum.reduce(%{}, fn {k, default, _}, acc -> Map.put(acc, k, default) end)
    |> Map.merge(%{infinite_pages: 1})
  end

  defp params_filters(params) do
    @default_filters
    |> Enum.reduce(%{}, fn {k, default, type}, acc ->
      if params[Atom.to_string(k)] do
        Map.put(acc, k, parse_param(params[Atom.to_string(k)], default, type))
      else
        acc
      end
    end)
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

  defp at_index(_, nil), do: nil
  defp at_index(_, false), do: nil
  defp at_index(collection, index), do: Enum.at(collection, index)

  defp find_index(_, nil), do: nil
  defp find_index(_, %{id: nil}), do: nil
  defp find_index(collection, %{id: id}), do: find_index(collection, id)
  defp find_index(collection, item), do: Enum.find_index(collection, &(&1 == item))

  # defp to_ids_map(enumerable), do: Enum.map(enumerable, &{&1.id, &1}) |> Map.new()
end
