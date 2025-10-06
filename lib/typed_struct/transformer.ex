defmodule AshOutstanding.TypedStruct.Transformer do
  @moduledoc false

  use Spark.Dsl.Transformer

  @impl true
  def transform(dsl) do
    AshOutstanding.TransformerHelper.transform(dsl, fn dsl, _options ->
      fields = Ash.TypedStruct.Info.fields(dsl)
      fields
    end)
  end
end
