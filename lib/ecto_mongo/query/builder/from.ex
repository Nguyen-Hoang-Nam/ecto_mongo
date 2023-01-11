defmodule EctoMongo.Query.Builder.From do
  def build(query) do
    query
    |> case do
      document when is_atom(document) ->
        source = quote(do: unquote(document).__schema__(:source))

        %EctoMongo.Query{from: query(source)}
    end
  end

  defp query(source) do
    [source: source]
  end
end
