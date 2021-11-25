defmodule OzfariumWeb.Live.Gallery.Form do
  use OzfariumWeb, :live_component

  alias Ozfarium.Gallery

  @impl true
  def update(%{ozfa: ozfa} = assigns, socket) do
    changeset = Gallery.change_ozfa(ozfa)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(changeset: changeset)
     |> allow_upload(:images,
       accept: ~W(.png .jpg .jpeg),
       max_file_size: 10_485_760,
       max_entries: if(ozfa.id, do: 1, else: 5)
     )}
  end

  @impl true
  def handle_event("validate", %{"ozfa" => ozfa_params}, socket) do
    changeset =
      socket.assigns.ozfa
      |> Gallery.change_ozfa(sanitize_text(ozfa_params))
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"ozfa" => ozfa_params}, socket) do
    uploaded_files = consume_files(socket)

    case Gallery.save_ozfa(socket.assigns.ozfa, sanitize_text(ozfa_params), uploaded_files) do
      {:ok, ozfa} ->
        send(
          self(),
          {if(socket.assigns.action == :new, do: :created_ozfa, else: :updated_ozfa),
           %{ozfa: ozfa}}
        )

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("select-ozfa-type", %{"target" => ozfa_type}, socket) do
    {:noreply,
     assign(
       socket,
       :changeset,
       Ecto.Changeset.put_change(socket.assigns.changeset, :type, ozfa_type)
     )}
  end

  def handle_event("cancel-images-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :images, ref)}
  end

  def type_tabs do
    %{
      "image" => gettext("Image"),
      "text" => gettext("Text"),
      "video" => gettext("Video")
    }
  end

  def type_form_component(type) do
    case type do
      "image" -> OzfariumWeb.Live.Gallery.Form.ImageType
      "text" -> OzfariumWeb.Live.Gallery.Form.TextType
      "video" -> OzfariumWeb.Live.Gallery.Form.VideoType
    end
  end

  defp sanitize_text(params) do
    Map.put(
      params,
      "content",
      HtmlSanitizeEx.strip_tags(Map.get(params, "content", ""))
    )
  end

  defp consume_files(socket) do
    host = build_host()

    consume_uploaded_entries(socket, :images, fn %{path: temp_path}, entry ->
      image = File.read!(temp_path)
      path = "#{entry.uuid}.#{ext(entry)}"
      upload_image(path, image)
      # Phoenix.LiveView.Upload.update_progress(socket, :images, entry.ref, 50)

      %{
        url: "#{host}/#{path}",
        size: entry.client_size
      }
    end)
  end

  defp upload_image(path, file) do
    ExAws.S3.put_object(Application.fetch_env!(:ex_aws, :s3_bucket), path, file)
    |> ExAws.request!()
  end

  defp ext(%{client_name: name}) do
    name |> String.split(".") |> List.last()
  end

  defp build_host() do
    "//#{Application.fetch_env!(:ex_aws, :s3_bucket)}.s3-#{Application.fetch_env!(:ex_aws, :region)}.amazonaws.com"
  end
end
