defmodule EctoMongo.Repo.Schema do
  require EctoMongo.Query
  require Logger

  def insert(repo, name, %Ecto.Changeset{} = changeset) do
    do_insert(repo, name, changeset)
  end

  def insert(repo, name, %{__struct__: _} = struct) do
    do_insert(repo, name, Ecto.Changeset.change(struct))
  end

  def update(repo, name, queryable, %Ecto.Changeset{} = changeset) do
    do_update(repo, name, queryable, changeset)
  end

  def update(repo, name, queryable, %{__struct__: _} = struct) do
    do_update(repo, name, queryable, Ecto.Changeset.change(struct))
  end

  defp do_insert(
         repo,
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
            {:ok,
             module
             |> EctoMongo.Query.query(_id: ^id)
             |> repo.one()}

          e ->
            e
        end

      e ->
        e
    end
  end

  defp do_insert(repo, _name, %Ecto.Changeset{valid?: false} = changeset) do
    {:error, put_repo_and_action(changeset, :insert, repo)}
  end

  defp do_update(
         repo,
         name,
         queryable,
         %Ecto.Changeset{valid?: true, data: %{__struct__: module}, changes: changes} = changeset
       ) do
    changeset
    |> Ecto.Changeset.apply_action(:update)
    |> case do
      {:ok, v} ->
        %{query: query} =
          queryable
          |> EctoMongo.Queryable.to_query()

        name
        |> Mongo.update_one(module.__document__(:source) |> elem(0), query, %{"$set" => changes})
        |> tap(fn v -> v |> inspect() |> Logger.error() end)
        |> case do
          {:ok, %{matched_count: 0}} ->
            {:ok, nil}

          {:ok, _} ->
            {:ok,
             queryable
             |> repo.one()}

          e ->
            e
        end

      e ->
        e
    end
  end

  defp do_update(repo, _name, _queryable, %Ecto.Changeset{valid?: false} = changeset) do
    {:error, put_repo_and_action(changeset, :update, repo)}
  end

  defp put_repo_and_action(
         %{action: :ignore, valid?: valid?} = changeset,
         action,
         repo
       ) do
    if valid? do
      raise ArgumentError,
            "a valid changeset with action :ignore was given to " <>
              "#{inspect(repo)}.#{action}/2. Changesets can only be ignored " <>
              "in a repository action if they are also invalid"
    else
      %{changeset | action: action, repo: repo}
    end
  end

  defp put_repo_and_action(%{action: given}, action, repo)
       when given != nil and given != action,
       do:
         raise(
           ArgumentError,
           "a changeset with action #{inspect(given)} was given to #{inspect(repo)}.#{action}/2"
         )

  defp put_repo_and_action(changeset, action, repo),
    do: %{changeset | action: action, repo: repo}
end
