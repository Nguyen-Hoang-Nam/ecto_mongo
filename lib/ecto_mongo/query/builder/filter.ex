defmodule EctoMongo.Query.Builder.Filter do
  require Logger

  def escape(expr) when is_list(expr) do
    expr
    |> Enum.map(fn
      {k, v} -> {k, v |> escape()}
      _ -> nil
    end)
    |> Enum.reject(&is_nil/1)
    |> Map.new()
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
      {:ne, v} -> {"$ne", v}
      {:nin, v} -> {"$nin", v}
      _ -> nil
    end)
    |> Enum.reject(&is_nil/1)
    |> Map.new()
  end

  def escape(value) do
    value
  end

  def build(:filter, :and, queryable, expr) do
    escape_expr = expr |> escape() |> Macro.escape()

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
