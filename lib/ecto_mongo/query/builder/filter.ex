defmodule EctoMongo.Query.Builder.Filter do
  def escape(expr) when is_list(expr) do
    expr =
      expr
      |> Enum.map(fn
        {k, v} -> {k, v |> escape()}
        _ -> nil
      end)
      |> Enum.reject(&is_nil/1)

    {:%{}, [], expr}
  end

  def escape({:^, _, [var]}) do
    var
  end

  def escape({:%{}, _, expr}) when is_list(expr) do
    expr
    |> Enum.map(fn
      {:eq, v} -> {"$eq", v}
      {:gt, v} -> {"$gt", v}
      {:gte, v} -> {"$gte", v}
      {:in, v} -> {"$in", v}
      {:lt, v} -> {"$lt", v}
      {:lte, v} -> {"$lte", v}
      {:ne, v} when v |> is_list() -> {"$ne", v}
      {:nin, v} when v |> is_list() -> {"$nin", v}
      _ -> nil
    end)
    |> Enum.reject(&is_nil/1)
  end

  def escape(value) do
    value
  end

  def build(:filter, :and, queryable, expr) do
    escape_expr = expr |> escape()

    quote do
      unquote_queryable =
        unquote(queryable)
        |> is_atom()
        |> case do
          true ->
            unquote(queryable) |> EctoMongo.Queryable.to_query()

          _ ->
            unquote(queryable)
        end

      %{query: query} = unquote_queryable

      %{unquote_queryable | query: query |> Map.merge(unquote(escape_expr))}
    end
  end
end
