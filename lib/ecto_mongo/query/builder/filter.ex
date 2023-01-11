defmodule EctoMongo.Query.Builder.Filter do
  def build(:filter, :and, queryable, expr) do
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

      %{unquote_queryable | query: query |> Map.merge(unquote(expr))}
    end
  end
end
