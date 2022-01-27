defmodule OzfariumWeb.Helpers do
  use Phoenix.HTML
  import Phoenix.LiveView.Helpers, only: [sigil_H: 2]
  import OzfariumWeb.Gettext

  def from_markdown(markdown) do
    case Earmark.as_html(markdown || "") do
      {:ok, html, []} -> html |> raw()
      {:error, _, _} -> markdown
    end
  end

  def s3_url(path, variant \\ :original) do
    "#{Application.fetch_env!(:b2_client, :bucket_url)}#{Application.fetch_env!(:b2_client, :bucket)}/#{Atom.to_string(variant)}/#{path}"
  end

  def video_iframe_from_url(url) do
    url = "#{url}"

    cond do
      String.match?(url, ~r/youtube|youtu.be/) ->
        youtube_iframe_from_url(url)

      String.match?(url, ~r/vimeo/) ->
        vimeo_iframe_from_url(url)

      url == "" ->
        ""

      true ->
        error_alert(%{message: gettext("Can not process this url, please try another one")})
    end
  end

  def video_thumbnail_from_url(url) do
    url = "#{url}"

    cond do
      String.match?(url, ~r/youtube|youtu.be/) ->
        youtube_thumbnail_from_url(url)

      String.match?(url, ~r/vimeo/) ->
        vimeo_thumbnail_from_url(url)

      true ->
        ""
    end
  end

  def upload_error_msg(:too_large), do: gettext("Image too large")
  def upload_error_msg(:too_many_files), do: gettext("Too many files")
  def upload_error_msg(:not_accepted), do: gettext("Unacceptable file type")

  def error_alert(assigns) do
    ~H"""
    <div class={"flex bg-red-100 rounded-lg p-4 mb-4 text-sm text-red-700"} role="alert">
      <svg class="w-5 h-5 inline mr-3" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path></svg>
      <div>
        <%= assigns.message %>
      </div>
    </div>
    """
  end

  defp youtube_iframe_from_url(url) do
    assigns = %{}
    [code, starts_at] = extract_youtube_params(url)

    if code do
      ~H"""
      <div class="video-iframe-wrapper">
        <iframe
          src={"https://www.youtube-nocookie.com/embed/#{code}?autoplay=1&start=#{starts_at}"}
          title="YouTube video player"
          frameborder="0"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowfullscreen>
        </iframe>
      </div>
      """
    else
      error_alert(%{message: gettext("Something wrong with video url")})
    end
  end

  def youtube_thumbnail_from_url(url) do
    [code, _] = extract_youtube_params(url)

    "http://img.youtube.com/vi/#{code}/0.jpg"
  end

  def vimeo_thumbnail_from_url(_url) do
    # unfortunately it needs api call to fetch url
    ""
  end

  defp extract_youtube_params(url) do
    regex = ~r/^.*((m\.)?youtu\.be\/|vi?\/|u\/\w\/|embed\/|\?vi?=|\&vi?=)([^#\&\?]*).*/

    code =
      case Regex.run(regex, url) do
        nil -> nil
        captures -> captures |> List.last()
      end

    starts_at =
      case Regex.run(~r/t=([\d|h|m|s]+)/, url) do
        nil -> nil
        captures -> captures |> List.last()
      end

    [code, starts_at]
  end

  # https://vimeo.com/645283761#t=90s
  defp vimeo_iframe_from_url(url) do
    assigns = %{}
    [code, starts_at] = extract_vimeo_params(url)

    if code do
      ~H"""
      <div class="video-iframe-wrapper">
        <iframe
          src={"https://player.vimeo.com/video/#{code}?autoplay=1&title=0&byline=0&portrait=0#t=#{starts_at}"}
          frameborder="0"
          allow="autoplay; fullscreen; picture-in-picture"
          allowfullscreen></iframe>
      </div>
      <script src="https://player.vimeo.com/api/player.js"></script>
      """
    else
      error_alert(%{message: gettext("Something wrong with video url")})
    end
  end

  defp extract_vimeo_params(url) do
    regex =
      ~r/(?:http|https)?:?\/?\/?(?:www\.)?(?:player\.)?vimeo\.com\/(?:channels\/(?:\w+\/)?|groups\/(?:[^\/]*)\/videos\/|video\/|)(\d+)(?:|\/\?)/

    code =
      case Regex.run(regex, url) do
        nil -> nil
        captures -> captures |> List.last()
      end

    starts_at =
      case Regex.run(~r/t=(\d+)/, url) do
        nil -> nil
        captures -> captures |> List.last()
      end

    [code, starts_at]
  end
end
