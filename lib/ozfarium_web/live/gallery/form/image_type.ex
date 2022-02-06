defmodule OzfariumWeb.Live.Gallery.Form.ImageType do
  use OzfariumWeb, :live_component

  def processing_status(entry) do
    case Map.get(entry, :processing_error) || Map.get(entry, :processing_step) do
      :init -> "Начинаю"
      :optimize -> "Оптимизирую"
      :deduplicate -> "Ищу дупликаты"
      :resize_thumbnail -> "Делаю иконку"
      :resize_cover -> "Делаю обложку"
      :upload_to_s3 -> "Загружаю в облако"
      :save -> "Сохраняю озфа"
      :failed_to_generate_thimbnail -> "Не получилось сделать иконку"
      :failed_to_generate_cover -> "Не получилось сделать обложку"
      :failed_to_upload_to_s3 -> "Не получилось загрузить в облако"
      :failed_to_save -> "Не получилось сохранить озфа"
      _ -> ""
    end
  end
end
