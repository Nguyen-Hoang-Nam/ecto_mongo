defprotocol EctoMongo.Queryable do
  def to_query(data)
end

defimpl EctoMongo.Queryable, for: EctoMongo.Query do
  def to_query(query), do: query
end

defimpl EctoMongo.Queryable, for: Atom do
  def to_query(module) do
    try do
      module.__document__(:query)
    rescue
      UndefinedFunctionError ->
        message =
          if :code.is_loaded(module) do
            "the given module does not provide a schema"
          else
            "the given module does not exist"
          end

        raise Protocol.UndefinedError, protocol: @protocol, value: module, description: message
    end
  end
end
