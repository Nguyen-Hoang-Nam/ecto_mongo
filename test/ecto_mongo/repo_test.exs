defmodule EctoMongo.RepoTest do
  use ExUnit.Case, async: true

  require EctoMongo.Query

  defmodule MyParent do
    use EctoMongo.Document

    document "my_parent" do
      field(:n, :integer)
    end

    def changeset(struct, params) do
      Ecto.Changeset.cast(struct, params, [:n])
    end
  end

  defmodule PrepareRepo do
    use EctoMongo.Repo, otp_app: :ecto
  end

  setup do
    _ = PrepareRepo.start_link(url: "mongodb://localhost:27017/hello")
    :ok
  end

  test "all" do
    assert {:ok, %MyParent{n: 1}} =
             %MyParent{} |> MyParent.changeset(%{n: 1}) |> PrepareRepo.insert()

    assert %MyParent{n: 1} = MyParent |> EctoMongo.Query.query(n: 1) |> PrepareRepo.one()

    assert [%MyParent{n: 1} | _] =
             MyParent
             |> EctoMongo.Query.query(n: %{gt: 0})
             |> PrepareRepo.all()
  end
end
