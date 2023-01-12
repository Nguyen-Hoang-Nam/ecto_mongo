defmodule EctoMongo.Repo.Queryable do
  require EctoMongo.Query
  require Logger

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

      :one ->
        name
        |> Mongo.find_one(source, query)
        |> case do
          {:error, _} = e ->
            e

          nil ->
            {:ok, nil}

          document ->
            document |> inspect() |> Logger.error()

            module
            |> struct(document)
            |> Ecto.Changeset.apply_action(:document)
        end
    end
  end
end
