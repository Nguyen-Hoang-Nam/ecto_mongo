defmodule EctoMongo.Document do
  defmacro __using__([]) do
    quote do
      import EctoMongo.Document, only: [document: 2]

      use MakeEnumerable
      unquote(__use__(:ecto))
    end
  end

  defmacro document(source, do: definition) do
    quote do
      def __document__(:query) do
        %EctoMongo.Query{
          from: %EctoMongo.Query.FromExpr{
            source: unquote(source)
          }
        }
      end

      def __document__(:source) do
        unquote(source)
      end

      Ecto.Schema.embedded_schema do
        unquote(definition)
      end
    end
  end

  defp __use__(:ecto) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset
    end
  end
end
