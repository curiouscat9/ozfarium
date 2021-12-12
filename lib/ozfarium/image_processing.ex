defmodule Ozfarium.ImageProcessing do
  alias Vix.Vips.Image
  alias Vix.Vips.Operation

  def optimize(path, ext) do
    path = Path.absname(path)

    case ext do
      # "png" -> execute("~/.cargo/bin/oxipng -o 2 -i 0 -s #{path}")
      "png" -> execute("optipng -o2 -i0 -strip all #{path}")
      "jpg" -> execute("jpegtran -copy none -progressive -outfile #{path} #{path}")
      _ -> nil
    end
  end

  def generate_hash(path) do
    File.stream!(Path.absname(path), [], 2_048)
    |> Enum.reduce(:crypto.hash_init(:sha256), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end

  def generate_thumbnail(path) do
    with {:ok, img} <- Image.new_from_file(Path.absname(path)),
         {:ok, thumbnail} <- Operation.thumbnail_image(img, 400),
         {:ok, content} <- Image.write_to_buffer(thumbnail, ".jpg[Q=80]") do
      {content, Image.width(img), Image.height(img)}
    else
      _ -> nil
    end
  end

  def upload_files_to_s3(files) do
    with {:ok, {auth, bucket}} <- auth_s3(),
         true <- upload_files_to_s3(auth, bucket, files) do
      :ok
    else
      error -> error
    end
  end

  def upload_files_to_s3(auth, bucket, files) do
    Enum.map(files, fn {path, content} ->
      case B2Client.backend().upload(auth, bucket, content, path) do
        {:ok, _} -> true
        _ -> false
      end
    end)
    |> Enum.all?()
  end

  defp auth_s3 do
    with {:ok, auth} <-
           B2Client.backend().authenticate(
             Application.fetch_env!(:b2_client, :key),
             Application.fetch_env!(:b2_client, :app_key)
           ),
         {:ok, bucket} <-
           B2Client.backend().get_bucket(auth, Application.fetch_env!(:b2_client, :bucket)) do
      {:ok, {auth, bucket}}
    else
      _ -> {:error, "Failed to authenticate S3"}
    end
  end

  defp execute(command) do
    command |> String.to_charlist() |> :os.cmd()
  end
end
