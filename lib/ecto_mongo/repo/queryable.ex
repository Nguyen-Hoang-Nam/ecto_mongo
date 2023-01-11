defmodule EctoMongo.Repo.Queryable do
  require EctoMongo.Query

  def all(name, queryable) do
    query = queryable |> EctoMongo.Queryable.to_query()

    execute(:all, name, query) |> elem(1)
  end

  defp execute(operation, name, %{from: %{source: source}, query: query}) do
    operation
    |> case do
      :all ->
        name
        |> Mongo.find(source, query)
    end
  end
end
