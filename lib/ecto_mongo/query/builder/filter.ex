defmodule EctoMongo.Query.Builder.Filter do
  def build(:filter, :and, queryable, expr) do
    quote do
      %{query: query} =
        unquote(queryable)
        |> is_atom()
        |> case do
          true ->
            unquote(queryable) |> EctoMongo.Queryable.to_query()

          _ ->
            unquote(queryable)
        end

      %{query: query |> Map.merge(unquote(expr))}
    end
  end
end
