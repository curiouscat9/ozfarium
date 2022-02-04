defmodule OzfariumWeb.Live.Gallery.Utils do
  @default_filters [
    {:user_id, nil, :integer},
    {:page, 1, :integer},
    {:per_page, 24, :integer},
    {:listed, "", :string},
    {:rated, "", :string},
    {:type, "", :string},
    {:image_orientation, "", :string},
    {:by_tags, [], :id_list},
    {:all_tags, 0, :boolean},
    {:q, "", :string}
  ]

  def paginate_ozfa_ids(%{
        page: page,
        per_page: per_page,
        infinite_pages: infinite_pages,
        ozfa_ids: ozfa_ids
      }) do
    to = page * per_page - 1
    from = to - per_page * infinite_pages + 1
    Enum.slice(ozfa_ids, from..to)
  end

  def find_prev_next(%{ozfa_ids: ozfa_ids, ozfa: ozfa}) do
    current_index = find_index(ozfa_ids, ozfa)
    prev_index = current_index && current_index > 0 && current_index - 1
    next_index = current_index && current_index + 1

    {at_index(ozfa_ids, prev_index), at_index(ozfa_ids, next_index)}
  end

  def find_page_of_current_ozfa(%{
        page: page,
        per_page: per_page,
        infinite_pages: infinite_pages,
        ozfa_ids: ozfa_ids,
        ozfa: ozfa
      }) do
    on_page = div(find_index(ozfa_ids, ozfa) || 0, per_page) + 1
    on_shown_page? = on_page >= page - infinite_pages + 1 && on_page <= page

    cond do
      on_shown_page? -> {page, infinite_pages}
      on_page == page + 1 -> {on_page, infinite_pages + 1}
      on_page == page - 1 -> {page, infinite_pages + 1}
      true -> {on_page, 1}
    end
  end

  def default_filters do
    @default_filters
    |> Enum.reduce(%{}, fn {k, default, _}, acc -> Map.put(acc, k, default) end)
    |> Map.merge(%{infinite_pages: 1})
  end

  def params_filters(params) do
    @default_filters
    |> Enum.reduce(%{}, fn {k, default, type}, acc ->
      if params[Atom.to_string(k)] do
        Map.put(acc, k, parse_param(params[Atom.to_string(k)], default, type))
      else
        acc
      end
    end)
  end

  def filtered_uri_params(assigns) do
    @default_filters
    |> Enum.reduce(URI.decode_query(assigns.uri.query || ""), fn {k, default, type}, uri_params ->
      string_k =
        case type do
          :id_list -> "#{Atom.to_string(k)}[]"
          _ -> Atom.to_string(k)
        end

      uri_params = Map.delete(uri_params, string_k)

      if add_uri_param?(assigns, k, default) do
        Map.put(uri_params, k, assigns[k])
      else
        uri_params
      end
    end)
  end

  def add_uri_param?(assigns, key, default) do
    assigns[key] && assigns[key] != default &&
      !(key == :image_orientation && assigns[:type] != "image")
  end

  def parse_param(value, default, type) do
    case type do
      :integer -> parse_int(value, default)
      :boolean -> parse_bool(value, default)
      :string -> value || default
      :id_list -> parse_id_list(value)
    end
  end

  def parse_int(str, default) do
    case Integer.parse(str || "") do
      {int, _} -> int
      :error -> default
    end
  end

  def parse_bool(str, default) do
    case str do
      "1" -> 1
      "0" -> 0
      "true" -> 1
      "false" -> 0
      _ -> default
    end
  end

  def parse_id_list(%{} = value) do
    value
    |> Enum.map(fn {k, v} ->
      if v == "true" do
        parse_int(k, nil)
      else
        nil
      end
    end)
    |> Enum.filter(& &1)
  end

  def parse_id_list(_) do
    []
  end

  def default_filters_keys do
    Enum.map(@default_filters, &elem(&1, 0))
  end

  def to_ids_map(enumerable), do: Enum.map(enumerable, &{&1.id, &1}) |> Map.new()

  def at_index(_, nil), do: nil
  def at_index(_, false), do: nil
  def at_index(collection, index), do: Enum.at(collection, index)

  def find_index(_, nil), do: nil
  def find_index(_, %{id: nil}), do: nil
  def find_index(collection, %{id: id}), do: find_index(collection, id)
  def find_index(collection, item), do: Enum.find_index(collection, &(&1 == item))

  def sanitize_text(params) do
    Map.put(
      params,
      "content",
      HtmlSanitizeEx.strip_tags(Map.get(params, "content", ""))
    )
  end

  def listed_options do
    [
      {"ото всех", ""},
      {"в моем списке", "my_liked"},
      {"не в моем списке", "not_my_liked"},
      {"добавленные мной", "my_own"},
      {"скрытые мной", "my_hidden"}
    ]
  end

  def rated_options do
    [
      {"с любой оценкой", ""},
      {"оцененные мной", "my_rated"},
      {"неоцененные мной", "my_unrated"},
      {"оцененные кем-то", "all_rated"},
      {"неоцененные никем", "all_unrated"}
    ]
  end

  def type_options do
    [
      {"любой тип", ""},
      {"картинки", "image"},
      {"текстовые", "text"},
      {"видео", "video"}
    ]
  end

  def image_orientation_options do
    [
      {"любая ориентация", ""},
      {"горизонтальные", "horizontal"},
      {"вертикальные", "vertical"}
    ]
  end

  def all_tags_options do
    [
      {"любое из выбранных озв", 0},
      {"все выбранные озв", 1}
    ]
  end
end
