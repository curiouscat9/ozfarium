defmodule OzfariumWeb.Telegram.AuthController do
  use OzfariumWeb, :controller
  alias Ozfarium.Users

  action_fallback :error

  def signin(conn, params) do
    with :ok <- verify_params(params),
         {:ok, user} <- find_or_create_user(params) do
      conn
      |> put_session(:current_user_id, user.id)
      |> redirect(to: "/")
    end
  end

  defp verify_params(params) do
    key = :crypto.hash(:sha256, Application.get_env(:ozfarium, :telegram)[:bot_token])

    data_check_string =
      params
      |> Map.delete("hash")
      |> Enum.sort()
      |> Enum.map(fn {key, value} ->
        "#{key}=#{value}"
      end)
      |> Enum.join("\n")

    hash =
      :crypto.mac(:hmac, :sha256, key, data_check_string)
      |> Base.encode16(case: :lower)

    if hash == params["hash"] do
      :ok
    else
      {:error, "Could not verify Telegram callback params"}
    end
  end

  defp find_or_create_user(%{"id" => telegram_id} = params) do
    telegram_id
    |> String.to_integer()
    |> Users.get_user_by_telegram_id()
    |> case do
      nil ->
        Users.create_user_from_telegram_params(params)

      user ->
        {:ok, user}
    end
  end

  defp error(conn, _e) do
    conn
    |> put_flash(:error, "Invalid Telegram callback")
    |> redirect(to: "/signin")
  end
end
