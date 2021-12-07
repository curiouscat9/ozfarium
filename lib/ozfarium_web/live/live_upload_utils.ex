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

  def cancel_upload(socket, name) do
    upload = socket.assigns.uploads |> Map.fetch!(name)

    Enum.reduce(upload.entries, socket, fn entry, socket_acc ->
      Upload.cancel_upload(socket_acc, name, entry.ref)
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

  def entry_file_name(%{uuid: uuid, client_name: name}) do
    "#{uuid}.#{name |> String.split(".") |> List.last()}"
  end

  def upload_file_to_s3(path, file) do
    with {:ok, auth} =
           B2Client.backend().authenticate(
             Application.fetch_env!(:b2_client, :key),
             Application.fetch_env!(:b2_client, :app_key)
           ),
         {:ok, bucket} =
           B2Client.backend().get_bucket(auth, Application.fetch_env!(:b2_client, :bucket)),
         {:ok, _result} = B2Client.backend().upload(auth, bucket, file, path) do
      true
    end
  end
end
