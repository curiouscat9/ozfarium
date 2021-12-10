defmodule Ozfarium.ImageProcessing do
  def optimize(path, ext) do
    path = Path.absname(path)

    case ext do
      "png" -> execute("~/.cargo/bin/oxipng -o 2 -i 0 -s #{path}")
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

  defp execute(command) do
    command |> String.to_charlist() |> :os.cmd()
  end
end
