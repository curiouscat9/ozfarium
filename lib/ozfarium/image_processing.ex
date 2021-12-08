defmodule Ozfarium.ImageProcessing do
  def optimize(path, ext) do
    path = Path.absname(path)

    case ext do
      "png" -> execute("~/.cargo/bin/oxipng -o 2 -i 0 -s #{path}")
      "jpg" -> execute("jpegtran -copy none -progressive -outfile #{path} #{path}")
      _ -> nil
    end
  end

  defp execute(command) do
    command |> String.to_charlist() |> :os.cmd()
  end
end
