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
    changeset
    |> Ecto.Changeset.apply_action(:insert)
    |> case do
      {:ok, v} ->
        :mongo
        |> Mongo.insert_one(module.__document__(:source), v)
        |> case do
          {:ok, _} = v ->
            v

          e ->
            e
        end

      e ->
        e
    end
  end
end
