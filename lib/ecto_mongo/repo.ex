defmodule EctoMongo.Repo do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour EctoMongo.Repo

      {otp_app} = EctoMongo.Repo.Supervisor.compile_config(__MODULE__, opts)

      @otp_app otp_app
      @default_dynamic_repo opts[:default_dynamic_repo] || __MODULE__

      def config do
        {:ok, config} =
          EctoMongo.Repo.Supervisor.runtime_config(:runtime, __MODULE__, @otp_app, [])

        config
      end

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :supervisor
        }
      end

      def start_link(opts \\ []) do
        EctoMongo.Repo.Supervisor.start_link(__MODULE__, @otp_app, opts)
      end

      def stop(timeout \\ 5000) do
        Supervisor.stop(get_dynamic_repo(), :normal, timeout)
      end

      def get_dynamic_repo() do
        Process.get({__MODULE__, :dynamic_repo}, @default_dynamic_repo)
      end

      def transaction(fun_or_multi, opts \\ []) do
      end

      def in_transaction? do
      end

      def roll_back(value) do
      end

      def insert(struct, opts \\ []) do
      end

      def update(struct, opts \\ []) do
      end

      def delete(struct, opts \\ []) do
      end

      def insert!(struct, opts \\ []) do
      end

      def update!(struct, opts \\ []) do
      end

      def delete!(struct, opts \\ []) do
      end

      def all(queryable) do
        repo = get_dynamic_repo()
        EctoMongo.Repo.Queryable.all(repo, queryable)
      end

      def one(queryable, opts \\ []) do
      end

      def aggregate(queryable, aggregate, opts \\ [])

      def aggregate(queryable, aggregate, opts) do
      end
    end
  end

  @doc group: "User callbacks"
  @callback init(context :: :supervisor | :runtime, config :: Keyword.t()) ::
              {:ok, Keyword.t()} | :ignore

  @doc group: "Runtime API"
  @callback config() :: Keyword.t()

  @doc group: "Runtime API"
  @callback start_link(opts :: Keyword.t()) ::
              {:ok, pid}
              | {:error, {:already_started, pid}}
              | {:error, term}

  @doc group: "Runtime API"
  @callback stop(timeout) :: :ok

  @doc group: "Runtime API"
  @callback get_dynamic_repo() :: atom() | pid()

  @doc group: "Query API"
  @callback all(queryable :: EctoMongo.Queryable.t(), opts :: Keyword.t()) :: [
              EctoMongo.Schema.t() | term
            ]
end
