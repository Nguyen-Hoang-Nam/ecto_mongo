defmodule EctoMongo.DocumentTest do
  use ExUnit.Case, async: true

  @document_name "my document"

  defmodule Document do
    use EctoMongo.Document

    document "my document" do
      field(:name, :string, default: "eric")
      field(:email, :string)
      field(:password, :string)
      field(:array, {:array, :string})
    end
  end

  test "Document Metadata" do
    assert Document.__document__(:source) == @document_name
  end

  # test "Types Metadata" do
  #   assert Document.__schema__(:type, :name) == :string
  #   assert Document.__schema__(:type, :email) == :string
  #   assert Document.__schema__(:type, :password) == :string
  #   assert Document.__schema__(:type, :array) == {:array, :string}
  # end
end
