defmodule OzfariumWeb.AuthPlug do
  import Plug.Conn

  alias Ozfarium.Users

  def init(opts), do: opts

  def call(conn, _) do
    conn
    |> get_session(:current_user_id)
    |> case do
      nil ->
        nil

      id ->
        Users.get_user(id)
    end
    |> case do
      nil ->
        conn
        |> Phoenix.Controller.redirect(to: "/signin")
        |> halt()

      user ->
        conn
        |> assign(:current_user, user)
    end
  end
end
