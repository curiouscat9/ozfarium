defmodule OzfariumWeb.LiveUploadUtils do
  alias Phoenix.LiveView.{Utils, Upload, UploadConfig}

  def update_progress(socket, entry, value) do
    upload = socket.assigns.uploads |> Map.fetch!(entry.upload_config)

    Upload.update_progress(socket, upload.ref, entry.ref, value)
  end

  def change_upload_config(socket, name, %{} = opts) do
    uploads = socket.assigns.uploads
    config = uploads |> Map.fetch!(name)
    updated_config = Map.merge(config, opts)
    updated_uploads = uploads |> Map.put(name, updated_config)

    Utils.assign(socket, :uploads, updated_uploads)
  end

  def cancel_uploads(socket, name) do
    upload = socket.assigns.uploads |> Map.fetch!(name)

    Enum.reduce(upload.entries, socket, fn entry, socket_acc ->
      Upload.cancel_upload(socket_acc, name, entry.ref)
    end)
  end

  def mark_entry_as_processed(socket, entry) do
    upload =
      socket.assigns.uploads
      |> Map.fetch!(entry.upload_config)
      |> UploadConfig.update_entry(entry.ref, fn entry -> Map.put(entry, :processed?, true) end)

    new_uploads = Map.update!(socket.assigns.uploads, upload.name, fn _ -> upload end)
    Utils.assign(socket, :uploads, new_uploads)
  end

  def entries_for_processing(socket, name) do
    {entries, []} = Upload.uploaded_entries(socket, name)

    Enum.reduce(entries, [], fn entry, acc ->
      if Map.get(entry, :processed?) do
        acc
      else
        [entry | acc]
      end
    end)
  end

  def entry_file_meta(socket, entry) do
    upload = socket.assigns.uploads |> Map.fetch!(entry.upload_config)
    pid = UploadConfig.entry_pid(upload, entry)

    case GenServer.call(pid, :consume_start, :infinity) do
      {:ok, file_meta} ->
        file_meta

      {:error, :in_progress} ->
        raise RuntimeError, "cannot process file that is still in progress of uploading"
    end
  end

  def entry_ext(%{client_type: client_type}) do
    MIME.extensions(client_type) |> List.first()
  end

  def entry_file_name(%{uuid: uuid, client_name: name}) do
    "#{uuid}.#{name |> String.split(".") |> List.last()}"
  end
end
