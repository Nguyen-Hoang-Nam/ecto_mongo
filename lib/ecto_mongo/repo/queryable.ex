defmodule EctoMongo.Repo.Queryable do
  require EctoMongo.Query

  def all(name, queryable) do
    query = queryable |> EctoMongo.Queryable.to_query()

    execute(:all, name, query)
  end

  defp execute(operation, name, %{from: %{source: source}, query: query}) do
    operation
    |> case do
      :all ->
        :mongo
        |> Mongo.find(source, query)
    end
  end
end
