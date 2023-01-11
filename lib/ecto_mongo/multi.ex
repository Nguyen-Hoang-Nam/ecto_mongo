defmodule EctoMongo.Multi do
  defstruct operations: [], names: MapSet.new()

  alias __MODULE__
  alias EctoMongo.Changeset

  @type changes :: map
  @type run :: (EctoMongo.Repo.t(), changes -> {:ok | :error, any})
  @type fun(result) :: (changes -> result)
  @type merge :: (changes -> t) | {module, atom, [any]}
  @typep schema_or_source :: binary | {binary, module} | module
  @typep operation ::
           {:changeset, Changeset.t(), Keyword.t()}
           | {:run, run}
           | {:put, any}
           | {:inspect, Keyword.t()}
           | {:merge, merge}
           | {:update_all, EctoMongo.Query.t(), Keyword.t()}
           | {:delete_all, EctoMongo.Query.t(), Keyword.t()}
           | {:insert_all, schema_or_source, [map | Keyword.t()], Keyword.t()}
  @typep operations :: [{name, operation}]
  @typep names :: MapSet.t()
  @type name :: any
  @type t :: %__MODULE__{operations: operations, names: names}

  @spec new :: t
  def new do
    %Multi{}
  end

  @spec insert(
          t,
          name,
          Changeset.t() | Ecto.Schema.t() | fun(Changeset.t() | Ecto.Schema.t()),
          Keyword.t()
        ) :: t
  def insert(multi, name, changeset_or_struct_or_fun, opts \\ [])

  def insert(multi, name, changeset, opts) do
  end

  @spec update(
          t,
          name,
          Changeset.t() | Ecto.Schema.t() | fun(Changeset.t() | Ecto.Schema.t()),
          Keyword.t()
        ) :: t
  def update(multi, name, changeset_or_struct_or_fun, opts \\ [])

  def update(multi, name, changeset, opts) do
  end

  @spec delete(
          t,
          name,
          Changeset.t() | Ecto.Schema.t() | fun(Changeset.t() | Ecto.Schema.t()),
          Keyword.t()
        ) :: t
  def delete(multi, name, changeset_or_struct_or_fun, opts \\ [])

  def delete(multi, name, changeset, opts) do
  end

  @spec one(
          t,
          name,
          queryable :: Ecto.Queryable.t() | fun(Ecto.Queryable.t()),
          Keyword.t()
        ) :: t
  def one(multi, name, queryable_or_fun, opts \\ [])

  def one(multi, name, fun, opts) do
  end

  @spec all(
          t,
          name,
          queryable :: Ecto.Queryable.t() | fun(Ecto.Queryable.t()),
          Keyword.t()
        ) :: t
  def all(multi, name, queryable_or_fun, opts \\ [])

  def all(multi, name, fun, opts) do
  end

  defp add_changeset(multi, action, name, changeset, opts) when is_list(opts) do
    add_operation(multi, name, {:changeset, put_action(changeset, action), opts})
  end

  defp put_action(%{action: nil} = changeset, action) do
    %{changeset | action: action}
  end

  defp put_action(%{action: action} = changeset, action) do
    changeset
  end

  defp put_action(%{action: original}, action) do
    raise ArgumentError,
          "you provided a changeset with an action already set " <>
            "to #{Kernel.inspect(original)} when trying to #{action} it"
  end

  @spec run(t, name, run) :: t
  def run(multi, name, run) when is_function(run, 2) do
    add_operation(multi, name, {:run, run})
  end

  @spec run(t, name, module, function, args) :: t when function: atom, args: [any]
  def run(multi, name, mod, fun, args)
      when is_atom(mod) and is_atom(fun) and is_list(args) do
    add_operation(multi, name, {:run, {mod, fun, args}})
  end

  defp add_operation(%Multi{} = multi, name, operation) do
    %{operations: operations, names: names} = multi

    if MapSet.member?(names, name) do
      raise "#{Kernel.inspect(name)} is already a member of the Ecto.Multi: \n#{Kernel.inspect(multi)}"
    else
      %{multi | operations: [{name, operation} | operations], names: MapSet.put(names, name)}
    end
  end

  defp apply_operations([], _names, _repo, _wrap, _return), do: {:ok, %{}}

  defp apply_operations(operations, names, repo, wrap, return) do
    wrap.(fn ->
      operations
      |> Enum.reduce({%{}, names}, &apply_operation(&1, repo, wrap, return, &2))
      |> elem(0)
    end)
  end

  defp apply_operation({name, operation}, repo, wrap, return, {acc, names}) do
    case apply_operation(operation, acc, {wrap, return}, repo) do
      {:ok, value} ->
        {Map.put(acc, name, value), names}

      {:error, value} ->
        return.({name, value, acc})

      other ->
        raise "expected Ecto.Multi callback named `#{Kernel.inspect(name)}` to return either {:ok, value} or {:error, value}, got: #{Kernel.inspect(other)}"
    end
  end

  defp apply_operation({:changeset, changeset, opts}, _acc, _apply_args, repo),
    do: apply(repo, changeset.action, [changeset, opts])

  defp apply_operation({:run, run}, acc, _apply_args, repo),
    do: apply_run_fun(run, repo, acc)

  defp apply_run_fun({mod, fun, args}, repo, acc), do: apply(mod, fun, [repo, acc | args])
  defp apply_run_fun(fun, repo, acc), do: apply(fun, [repo, acc])
end
