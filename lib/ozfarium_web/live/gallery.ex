defmodule OzfariumWeb.Live.Gallery do
  use OzfariumWeb, :live_view

  import OzfariumWeb.LiveUploadUtils
  import OzfariumWeb.Live.Gallery.Utils
  import OzfariumWeb.Live.Gallery.ProcessImage

  alias Ozfarium.Gallery
  alias Ozfarium.Gallery.Ozfa
  alias Ozfarium.Users
  alias Ozfarium.Tags

  @impl true
  def mount(params, session, socket) do
    {:ok,
     assign(socket,
       ozfa: nil,
       preloaded_ozfas: %{},
       paginated_ozfas: [],
       saved_ozfas: [],
       current_user: Users.get_user(session["current_user_id"]),
       tags: Tags.list_tags(),
       processing_images: false
     )
     |> assign(default_filters())
     |> assign(params_filters(params))
     |> assign_filtered_ozfa_ids()
     |> assign_paginated_ozfas()
     |> allow_upload(:images,
       accept: ~W(.png .jpg .jpeg),
       max_file_size: 10_485_760
     )}
  end

  @impl true
  def handle_params(params, uri, socket) do
    socket = assign(socket, :uri, URI.parse(uri))
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Галерея")
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    ozfa = Gallery.preload_ozfa!(socket.assigns.current_user, id)

    socket
    |> assign(page_title: "Озфа #{id}", ozfa: ozfa)
    |> assign_page_of_current_ozfa()
    |> assign_paginated_ozfas()
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    ozfa = Gallery.preload_ozfa!(socket.assigns.current_user, id)
    changeset = Gallery.change_ozfa(ozfa)

    socket
    |> assign(
      page_title: "Редактирование Озфа",
      ozfa: ozfa,
      changeset: changeset,
      saved_ozfas: []
    )
    |> change_upload_config(:images, %{max_entries: 1})
  end

  defp apply_action(socket, :new, _params) do
    ozfa = %Ozfa{}
    changeset = Gallery.change_ozfa(ozfa)

    socket
    |> assign(page_title: "Добавление Озфа", ozfa: ozfa, changeset: changeset, saved_ozfas: [])
    |> change_upload_config(:images, %{max_entries: 32})
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
  def handle_event("nav-next", _, socket) do
    {:noreply, push_patch(socket, to: Routes.gallery_path(socket, :show, socket.assigns.next))}
  end

  @impl true
  def handle_event("nav-prev", _, socket) do
    {:noreply, push_patch(socket, to: Routes.gallery_path(socket, :show, socket.assigns.prev))}
  end

  @impl true
  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply,
     assign(socket, page: assigns.page + 1, infinite_pages: assigns.infinite_pages + 1)
     |> assign_paginated_ozfas()
     |> push_patch_to_index()}
  end

  @impl true
  def handle_event("filter", %{"_target" => ["filter" | _], "filter" => params}, socket) do
    {:noreply,
     assign(socket, params_filters(params))
     |> assign_filtered_ozfa_ids()
     |> assign(page: 1, infinite_pages: 1)
     |> assign_paginated_ozfas()
     |> push_patch_to_index()}
  end

  @impl true
  def handle_event("filter", %{}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("select-ozfa-type", %{"target" => ozfa_type}, socket) do
    changeset = Ecto.Changeset.put_change(socket.assigns.changeset, :type, ozfa_type)

    {:noreply, assign(socket, :changeset, changeset) |> cleanup_uploads()}
  end

  @impl true
  def handle_event("validate", %{"ozfa" => ozfa_params}, socket) do
    changeset =
      socket.assigns.ozfa
      |> Gallery.change_ozfa(sanitize_text(ozfa_params))
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"ozfa" => %{"type" => "image"}}, socket) do
    send(self(), :process_next_image)

    {:noreply, assign(socket, :processing_images, true)}
  end

  @impl true
  def handle_event("save", %{"ozfa" => ozfa_params}, %{assigns: assigns} = socket) do
    case Gallery.save_ozfa(assigns.ozfa, assigns.current_user, sanitize_text(ozfa_params)) do
      {:ok, ozfa} ->
        {:noreply, after_saved_ozfa(socket, ozfa, :complete)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def handle_event("cancel-images-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :images, ref)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, %{assigns: assigns} = socket) do
    ozfa = Gallery.preload_ozfa!(assigns.current_user, id)
    user_ozfa = ozfa.user_ozfas |> List.first()

    if user_ozfa && user_ozfa.owned do
      {:ok, _} = Gallery.delete_ozfa(ozfa)

      {:noreply, after_visibility_update(socket, ozfa)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("take", %{"id" => id}, %{assigns: assigns} = socket) do
    ozfa = Gallery.get_ozfa!(id)
    Gallery.find_or_create_user_ozfa(ozfa, assigns.current_user)

    {:noreply, after_visibility_update(socket, ozfa)}
  end

  @impl true
  def handle_event("untake", %{"id" => id}, %{assigns: assigns} = socket) do
    ozfa = Gallery.get_ozfa!(id)
    Gallery.delete_user_ozfa(ozfa, assigns.current_user)

    {:noreply, after_visibility_update(socket, ozfa)}
  end

 @impl true
def handle_event("increment-ep-count", %{"id" => id}, %{assigns: assigns} = socket) do
  ozfa = Gallery.get_ozfa!(id)
  user_ozfa = Gallery.find_user_ozfa(ozfa, assigns.current_user)

  current_ep_timestamps = user_ozfa.ep_timestamps || []

  updated_ep_timestamps = [
    NaiveDateTime.utc_now() | current_ep_timestamps
  ]

  Gallery.update_user_ozfa(user_ozfa, %{ep_timestamps: updated_ep_timestamps})
  {:noreply, after_visibility_update(socket, ozfa)}
end

  
  @impl true
  def handle_event("decrement-ep-count", %{"id" => id}, %{assigns: assigns} = socket) do
    ozfa = Gallery.get_ozfa!(id)
    user_ozfa = Gallery.find_user_ozfa(ozfa, assigns.current_user)
    current_ep_timestamps = user_ozfa.ep_timestamps

    if Enum.any?(current_ep_timestamps) do
      updated_ep_timestamps = Enum.drop(current_ep_timestamps, 1)
      Gallery.update_user_ozfa(user_ozfa, %{ep_timestamps: updated_ep_timestamps})
    end

    {:noreply, after_visibility_update(socket, ozfa)}
  end


  @impl true
  def handle_event("hide", %{"id" => id}, %{assigns: assigns} = socket) do
    ozfa = Gallery.get_ozfa!(id)
    Gallery.update_or_create_user_ozfa(ozfa, assigns.current_user, %{hidden: true})

    {:noreply, after_visibility_update(socket, ozfa)}
  end

  @impl true
  def handle_event("unhide", %{"id" => id}, %{assigns: assigns} = socket) do
    ozfa = Gallery.get_ozfa!(id)
    Gallery.update_or_create_user_ozfa(ozfa, assigns.current_user, %{hidden: false})

    {:noreply, after_visibility_update(socket, ozfa)}
  end

  @impl true
  def handle_event("rate-tag", params, %{assigns: assigns} = socket) do
    ozfa = Gallery.get_ozfa!(params["ozfa_id"])
    tag = Tags.get_tag!(params["tag_id"])

    case Users.rate_ozfa(assigns.current_user, ozfa, tag, params["rating"]) do
      {:ok, _} ->
        {:noreply, assign(socket, ozfa: Gallery.preload_ozfa!(assigns.current_user, ozfa.id))}

      {:error, changeset} ->
        changeset |> IO.inspect(label: "rate event fail", limit: :infinity)

        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply,
     socket
     |> cleanup_uploads()
     |> push_patch_to_index()}
  end

  @impl true
  def handle_info(:process_next_image, socket) do
    case entries_for_processing(socket, :images) do
      [] ->
        ozfa = socket.assigns.saved_ozfas |> List.first()

        {:noreply,
         assign(socket, :processing_images, false)
         |> after_saved_ozfa(ozfa, upload_status(socket))}

      [entry | _] ->
        handle_process_image_step(socket, :init, entry)
    end
  end

  @impl true
  def handle_info({:process_image, step, entry}, socket) do
    handle_process_image_step(socket, step, entry)
  end

  def handle_process_image_step(socket, step, entry) do
    case process_image_step(socket, step, entry) do
      {socket, :process_next_image} ->
        send(self(), :process_next_image)
        {:noreply, socket}

      {socket, next_step, entry} ->
        send(self(), {:process_image, next_step, entry})
        {:noreply, socket}
    end
  end

  def after_saved_ozfa(%{assigns: %{live_action: :new}} = socket, ozfa, status) do
    socket =
      assign(socket, ozfa: ozfa || socket.assigns.ozfa)
      |> assign(default_filters() |> Map.merge(%{listed: "my_own"}))
      |> assign_filtered_ozfa_ids()
      |> assign_paginated_ozfas()

    if status == :complete do
      push_patch_to_index(socket)
    else
      socket
    end
  end

  def after_saved_ozfa(%{assigns: %{live_action: :edit}} = socket, ozfa, status) do
    socket =
      socket
      |> assign(ozfa: ozfa, preloaded_ozfas: Map.delete(socket.assigns.preloaded_ozfas, ozfa.id))
      |> assign_paginated_ozfas()

    if status == :complete do
      push_patch(socket, to: Routes.gallery_path(socket, :show, ozfa.id))
    else
      socket
    end
  end

  def after_visibility_update(%{assigns: assigns} = socket, ozfa) do
    socket
    |> assign_filtered_ozfa_ids()
    |> assign_ozfa_or_fallback(ozfa.id, assigns.next || assigns.prev)
    |> assign_page_of_current_ozfa()
    |> assign_paginated_ozfas()
  end

  defp assign_filtered_ozfa_ids(%{assigns: assigns} = socket) do
    assign(socket,
      ozfa_ids:
        Gallery.list_ozfas(assigns.current_user, Map.take(assigns, default_filters_keys()))
    )
  end

  def assign_ozfa_or_fallback(%{assigns: assigns} = socket, id, fallback_id) do
    id = if(Enum.member?(assigns.ozfa_ids, id), do: id, else: fallback_id)

    assign(socket, ozfa: Gallery.preload_ozfa!(assigns.current_user, id))
  end

  defp assign_page_of_current_ozfa(socket) do
    {page, infinite_pages} = find_page_of_current_ozfa(socket.assigns)

    assign(socket, page: page, infinite_pages: infinite_pages)
  end

  defp assign_paginated_ozfas(%{assigns: assigns} = socket) do
    paginated_ids = paginate_ozfa_ids(assigns)

    preloaded_ozfas =
      Gallery.preload_missing_ozfas(assigns.current_user, assigns.preloaded_ozfas, paginated_ids)

    {prev, next} = find_prev_next(assigns)

    assign(socket,
      preloaded_ozfas: preloaded_ozfas,
      paginated_ozfas: Enum.map(paginated_ids, fn id -> preloaded_ozfas[id] end),
      total_count: Enum.count(assigns.ozfa_ids),
      page_count: div(Enum.count(assigns.ozfa_ids) - 1, assigns.per_page) + 1,
      prev: prev,
      next: next
    )
  end

  defp push_patch_to_index(socket) do
    push_patch(socket, to: index_path(socket))
  end

  defp index_path(socket) do
    Routes.gallery_path(socket, :index, filtered_uri_params(socket.assigns))
  end

  defp cleanup_uploads(socket) do
    socket
    |> cancel_uploads(:images)
    |> assign(saved_ozfas: [])
  end
end
