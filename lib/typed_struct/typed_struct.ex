defmodule AshOutstanding.TypedStruct do
  @moduledoc """
  `Ash.TypedStruct` extension for implementing `Outstanding` protocol.
  """

  use Spark.Dsl.Extension,
    sections: [AshOutstanding.Extension.section(Ash.TypedStruct)],
    transformers: [AshOutstanding.TypedStruct.Transformer]
end
