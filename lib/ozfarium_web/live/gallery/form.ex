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
       max_entries: if(ozfa.id, do: 1, else: 5),
       external: &presign_upload/2
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
    uploaded_files =
      consume_uploaded_entries(socket, :images, fn meta, entry ->
        %{
          url: "#{meta.url}/#{meta.key}",
          size: entry.client_size
        }
      end)

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

  defp presign_upload(entry, socket) do
    uploads = socket.assigns.uploads
    bucket = Application.fetch_env!(:ozfarium, :aws_bucket)
    key = "public/#{entry.client_name}"

    config = %{
      region: Application.fetch_env!(:ozfarium, :aws_region),
      access_key_id: Application.fetch_env!(:ozfarium, :aws_access_key_id),
      secret_access_key: Application.fetch_env!(:ozfarium, :aws_secret_access_key)
    }

    {:ok, fields} =
      SimpleS3Upload.sign_form_upload(config, bucket,
        key: key,
        content_type: entry.client_type,
        max_file_size: uploads.images.max_file_size,
        expires_in: :timer.hours(1)
      )

    meta = %{
      uploader: "S3",
      key: key,
      url: "http://#{bucket}.s3-#{config.region}.amazonaws.com",
      fields: fields
    }

    {:ok, meta, socket}
  end
end
