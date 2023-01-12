defmodule EctoMongo.Repo.Schema do
  require EctoMongo.Query
  require Logger

  def insert(repo, name, %Ecto.Changeset{} = changeset) do
    do_insert(repo, name, changeset)
  end

  def insert(repo, name, %{__struct__: _} = struct) do
    do_insert(repo, name, Ecto.Changeset.change(struct))
  end

  defp do_insert(
         _repo,
         name,
         %Ecto.Changeset{valid?: true, data: %{__struct__: module}} = changeset
       ) do
    changeset
    |> Ecto.Changeset.apply_action(:insert)
    |> case do
      {:ok, v} ->
        name
        |> Mongo.insert_one(module.__document__(:source) |> elem(0), v)
        |> case do
          {:ok, %{inserted_id: id}} ->
            name
            |> EctoMongo.Repo.Queryable.one(
              module
              |> EctoMongo.Query.query(_id: ^id)
              |> tap(fn v -> v |> inspect() |> Logger.error() end)
            )

          e ->
            e
        end

      e ->
        e
    end
  end

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
