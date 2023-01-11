defmodule EctoMongo.Repo.Schema do
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
    name
    |> Mongo.insert_one(module.__document__(:source), changeset)
    |> case do
      {:ok, _} = v ->
        v

      e ->
        e
    end
  end
end
