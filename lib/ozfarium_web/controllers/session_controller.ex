defmodule OzfariumWeb.SessionController do
  use OzfariumWeb, :controller

  def new(conn, _params) do
    render(conn)
  end

  def delete(conn, _params) do
    conn
    |> put_session(:current_user_id, nil)
    |> redirect(to: "/")
  end
end
