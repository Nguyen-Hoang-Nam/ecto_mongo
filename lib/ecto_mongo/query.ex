defmodule EctoMongo.Query do
  alias EctoMongo.Query.Builder

  defstruct from: nil, query: %{}

  defmodule FromExpr do
    defstruct [:source]
  end

  defmacro from(expr) do
    Builder.From.build(expr)
  end

  defmacro query(query, expr) do
    Builder.Filter.build(:filter, :and, query, expr)
  end
end
