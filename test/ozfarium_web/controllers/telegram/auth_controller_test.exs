defmodule OzfariumWeb.Telegram.AuthControllerTest do
  use OzfariumWeb.ConnCase

  alias Ozfarium.Users

  describe "Signing in" do
    test "creates user and assigns current_user_id", %{conn: conn} do
      get(
        conn,
        Routes.auth_path(conn, :signin, %{
          "auth_date" => "1621758992",
          "first_name" => "Max",
          "hash" => "bb91904ce6e02e414a8a53605848a7e98d581b4adf2f53fe37593db7dc9fccfe",
          "id" => "2144377",
          "last_name" => "Grin",
          "photo_url" =>
            "https://t.me/i/userpic/320/-wRdfHGcHWGv7nSR0QUm2oNc0VYGGr3wyJsa6En2Pbk.jpg",
          "username" => "mxgrn"
        })
      )

      assert user = Users.get_user_by_telegram_id(2_144_377)
      assert user.telegram_username == "mxgrn"
    end
  end
end
