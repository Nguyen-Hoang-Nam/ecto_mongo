defmodule EctoMongo.Repo.Queryable do
  require EctoMongo.Query

  def all(name, queryable) do
    query = queryable |> EctoMongo.Queryable.to_query()

    execute(:all, name, query)
  end

  def one(name, queryable) do
    query = queryable |> EctoMongo.Queryable.to_query()

    execute(:one, name, query)
  end

  defp execute(operation, name, %{from: %{source: {source, module}}, query: query}) do
    operation
    |> case do
      :all ->
        name
        |> Mongo.find(source, query)
        |> case do
          %{docs: docs} ->
            docs
            |> Enum.map(fn doc ->
              module
              |> to_struct(doc)
            end)

          {:error, e} ->
            e
        end

      :one ->
        name
        |> Mongo.find_one(source, query)
        |> case do
          {:error, e} ->
            e

          nil ->
            nil

          document ->
            module
            |> to_struct(document)
        end
    end
  end

  # Credit: https://groups.google.com/g/elixir-lang-talk/c/6geXOLUeIpI/m/L9einu4EEAAJ
  def to_struct(kind, attrs) do
    struct = struct(kind)

    Enum.reduce(Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(attrs, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end)
  end
end
