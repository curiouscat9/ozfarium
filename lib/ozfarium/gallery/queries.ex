defmodule Ozfarium.Gallery.Queries do
  import Ecto.Query, warn: false

  alias Ozfarium.Gallery.Ozfa
  alias Ozfarium.Users.UserOzfa
  alias Ozfarium.Users.UserOzfaTag

  def preload_ozfas(user, ids) do
    user_ozfas_query = from uo in UserOzfa, where: uo.user_id == ^user.id

    query =
      from(o in Ozfa,
        where: o.id in ^ids,
        preload: [user_ozfas: ^user_ozfas_query]
      )

    if Enum.count(ids) == 1 do
      user_ozfa_tags_query = from uot in UserOzfaTag, where: uot.user_id == ^user.id

      from(o in query,
        preload: [user_ozfa_tags: ^user_ozfa_tags_query]
      )
    else
      query
    end
  end

  def filter_ozfas(query, user, filters) do
    filters |> IO.inspect(label: "filters", limit: :infinity)

    query =
      query
      |> filter_listed(user, filters)
      |> filter_rated(user, filters)
      |> filter_type(filters)
      |> filter_image_orientation(filters)

    from(o in query, order_by: [desc: o.inserted_at])
  end

  def filter_listed(query, user, %{listed: "my_liked"}) do
    from(o in query,
      join: uo in UserOzfa,
      on: uo.ozfa_id == o.id and uo.user_id == ^user.id and uo.hidden == false,
      order_by: [desc: uo.inserted_at]
    )
  end

  def filter_listed(query, user, %{listed: "not_my_liked"}) do
    owned_ozfas = from(uo in UserOzfa, where: uo.user_id == ^user.id, select: uo.ozfa_id)

    from(o in query, where: o.id not in subquery(owned_ozfas))
  end

  def filter_listed(query, user, %{listed: "my_own"}) do
    from(o in query,
      join: uo in UserOzfa,
      on:
        uo.ozfa_id == o.id and uo.user_id == ^user.id and uo.owned == true and
          uo.hidden == false,
      order_by: [desc: uo.inserted_at]
    )
  end

  def filter_listed(query, user, %{listed: "my_hidden"}) do
    from(o in query,
      join: uo in UserOzfa,
      on: uo.ozfa_id == o.id and uo.user_id == ^user.id and uo.hidden == true,
      order_by: [desc: uo.updated_at]
    )
  end

  def filter_listed(query, user, _) do
    hidden_ozfas =
      from(uo in UserOzfa,
        where: uo.user_id == ^user.id and uo.hidden == true,
        select: uo.ozfa_id
      )

    from(o in query, where: o.id not in subquery(hidden_ozfas))
  end

  def ratings_subquery(%{by_tags: by_tags, all_tags: all_tags}) do
    query =
      from(uot in UserOzfaTag, where: uot.rating > 0, select: uot.ozfa_id, distinct: uot.ozfa_id)

    if Enum.any?(by_tags) do
      if all_tags == 1 do
        from(uot in query,
          where: uot.tag_id in ^by_tags,
          group_by: uot.ozfa_id,
          having: count(uot.tag_id, :distinct) == ^Enum.count(by_tags)
        )
      else
        from(uot in query, where: uot.tag_id in ^by_tags)
      end
    else
      query
    end
  end

  def ratings_subquery(params, user) do
    from(uot in ratings_subquery(params), where: uot.user_id == ^user.id)
  end

  def filter_rated(query, user, %{rated: "my_rated"} = params) do
    from(o in query, where: o.id in subquery(ratings_subquery(params, user)))
  end

  def filter_rated(query, user, %{rated: "my_unrated"} = params) do
    from(o in query, where: o.id not in subquery(ratings_subquery(params, user)))
  end

  def filter_rated(query, _user, %{rated: "all_rated"} = params) do
    from(o in query, where: o.id in subquery(ratings_subquery(params)))
  end

  def filter_rated(query, _user, %{rated: "all_unrated"} = params) do
    from(o in query, where: o.id not in subquery(ratings_subquery(params)))
  end

  def filter_rated(query, _user, %{by_tags: by_tags} = params) do
    if by_tags && Enum.any?(by_tags) do
      from(o in query, where: o.id in subquery(ratings_subquery(params)))
    else
      query
    end
  end

  def filter_rated(query, _, _), do: query

  def filter_type(query, %{type: ""}), do: query

  def filter_type(query, %{type: type}) do
    from(o in query, where: o.type == ^type)
  end

  def filter_type(query, _), do: query

  def filter_image_orientation(query, %{type: "image", image_orientation: "horizontal"}) do
    from(o in query, where: o.width > o.height)
  end

  def filter_image_orientation(query, %{type: "image", image_orientation: "vertical"}) do
    from(o in query, where: o.width < o.height)
  end

  def filter_image_orientation(query, _), do: query
end
