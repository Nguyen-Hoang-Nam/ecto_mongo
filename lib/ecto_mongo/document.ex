defmodule EctoMongo.Document do
  defmacro __using__([]) do
    quote do
      import EctoMongo.Document, only: [document: 2]

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

      # Credit: https://github.com/basiliscos/ex-make_enumerable/blob/fed5f95952af7584213aeb23e7c386b493c20d0b/lib/make_enumerable.ex
      defimpl Enumerable, for: __MODULE__ do
        def reduce(map, acc, fun) do
          map = :maps.without([:__struct__], map)
          do_reduce(:maps.to_list(map), acc, fun)
        end

        defp do_reduce(_, {:halt, acc}, _fun), do: {:halted, acc}

        defp do_reduce(list, {:suspend, acc}, fun),
          do: {:suspended, acc, &do_reduce(list, &1, fun)}

        defp do_reduce([], {:cont, acc}, _fun), do: {:done, acc}
        defp do_reduce([h | t], {:cont, acc}, fun), do: do_reduce(t, fun.(h, acc), fun)

        def member?(map, {:__struct__, value}) do
          {:ok, false}
        end

        def member?(map, {key, value}) do
          {:ok, match?({:ok, ^value}, :maps.find(key, map))}
        end

        def member?(_map, _other) do
          {:ok, false}
        end

        def count(map) do
          {:ok, map_size(map) - 1}
        end
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
