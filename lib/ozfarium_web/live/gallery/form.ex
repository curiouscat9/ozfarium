defmodule OzfariumWeb.Live.Gallery.Form do
  use OzfariumWeb, :live_component

  def type_tabs do
    %{
      "image" => gettext("Image"),
      "text" => gettext("Text"),
      "video" => gettext("Video")
    }
  end

  def type_form_component(type) do
    case type do
      "image" -> OzfariumWeb.Live.Gallery.Form.ImageType
      "text" -> OzfariumWeb.Live.Gallery.Form.TextType
      "video" -> OzfariumWeb.Live.Gallery.Form.VideoType
    end
  end
end
