defmodule EctoMongo.Repo.Supervisor do
  use Supervisor

  @defaults [timeout: 15000, pool_size: 10]

  def start_link(repo, otp_app, opts) do
    Supervisor.start_link(__MODULE__, {repo, otp_app, opts |> Keyword.put(:name, repo)}, [])
  end

  def runtime_config(type, repo, otp_app, opts) do
    config = Application.get_env(otp_app, repo, [])
    config = [otp_app: otp_app] ++ (@defaults |> Keyword.merge(config) |> Keyword.merge(opts))

    case repo_init(type, repo, config) do
      {:ok, config} ->
        {:ok, config}

      :ignore ->
        :ignore
    end
  end

  defp repo_init(type, repo, config) do
    if Code.ensure_loaded?(repo) and function_exported?(repo, :init, 2) do
      repo.init(type, config)
    else
      {:ok, config}
    end
  end

  def compile_config(_repo, opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)

    {otp_app}
  end

  def init({repo, otp_app, opts}) do
    case runtime_config(:supervisor, repo, otp_app, opts) do
      {:ok, opts} ->
        child_spec = wrap_child_spec(opts)
        Supervisor.init([child_spec], strategy: :one_for_one, max_restarts: 0)

      :ignore ->
        :ignore
    end
  end

  def start_child({mod, fun, args}) do
    case apply(mod, fun, args) do
      {:ok, pid} ->
        {:ok, pid}

      other ->
        other
    end
  end

  defp wrap_child_spec(database_config) do
    %{
      id: Mongo,
      start: {__MODULE__, :start_child, [{Mongo, :start_link, [database_config]}]}
    }
  end
end
