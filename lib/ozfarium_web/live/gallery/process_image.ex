defmodule OzfariumWeb.Live.Gallery.ProcessImage do
  import OzfariumWeb.LiveUploadUtils
  import Phoenix.LiveView, only: [assign: 2, consume_uploaded_entry: 3]

  alias Ozfarium.ImageProcessing
  alias Ozfarium.Gallery

  def upload_status(socket) do
    if Enum.any?(socket.assigns.uploads.images.entries, &Map.get(&1, :processing_error)) do
      :incomplete
    else
      :complete
    end
  end

  def process_image_step(socket, :init, entry) do
    entry =
      entry
      |> Map.put(:temp_path, entry_file_meta(socket, entry).path)
      |> Map.put(:file_name, entry_file_name(entry))

    socket = update_entry(socket, entry, %{processing_step: :optimize, progress: 10})

    {socket, :optimize, entry}
  end

  def process_image_step(socket, :optimize, entry) do
    ImageProcessing.optimize(entry.temp_path, entry_ext(entry))

    socket = update_entry(socket, entry, %{processing_step: :deduplicate, progress: 20})

    {socket, :deduplicate, entry}
  end

  def process_image_step(socket, :deduplicate, entry) do
    hash = ImageProcessing.generate_hash(entry.temp_path)

    case Gallery.get_ozfa_by(hash: hash) do
      nil ->
        entry = Map.put(entry, :hash, hash)
        socket = update_entry(socket, entry, %{processing_step: :resize, progress: 40})
        {socket, :resize, entry}

      ozfa ->
        Gallery.add_user(ozfa, socket.assigns.current_user)

        socket =
          socket
          |> assign(saved_ozfas: [%{ozfa | duplicate?: true} | socket.assigns.saved_ozfas])
          |> consume_entry(entry)

        {socket, :process_next_image}
    end
  end

  def process_image_step(socket, :resize, entry) do
    case ImageProcessing.generate_thumbnail(entry.temp_path) do
      {thumbnail, width, height} ->
        entry = Map.merge(entry, %{thumbnail: thumbnail, width: width, height: height})
        socket = update_entry(socket, entry, %{processing_step: :upload_to_s3, progress: 60})
        {socket, :upload_to_s3, entry}

      nil ->
        socket = update_entry(socket, entry, %{processing_error: "Failed to generate thumbnail"})
        {socket, :process_next_image}
    end
  end

  def process_image_step(socket, :upload_to_s3, entry) do
    case ImageProcessing.upload_files_to_s3([
           {"original/#{entry.file_name}", File.read!(entry.temp_path)},
           {"thumbnail/#{entry.file_name}", entry.thumbnail}
         ]) do
      :ok ->
        socket = update_entry(socket, entry, %{processing_step: :save, progress: 90})
        {socket, :save, entry}

      _ ->
        socket = update_entry(socket, entry, %{processing_error: "Failed to upload to S3"})
        {socket, :process_next_image}
    end
  end

  def process_image_step(%{assigns: assigns} = socket, :save, entry) do
    socket =
      case Gallery.save_image(assigns.ozfa, assigns.current_user, entry) do
        {:ok, ozfa} ->
          assign(socket, saved_ozfas: [ozfa | socket.assigns.saved_ozfas])

        {:error, _} ->
          update_entry(socket, entry, %{processing_error: "Failed to save Ozfa"})
      end

    {consume_entry(socket, entry), :process_next_image}
  end

  defp consume_entry(socket, entry) do
    consume_uploaded_entry(socket, entry, &{:ok, &1})
    update_entry(socket, entry, %{processed?: true})
  end
end
