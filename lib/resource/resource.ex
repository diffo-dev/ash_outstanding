defmodule AshOutstanding.Resource do
  @moduledoc """
  `Ash.Resource` extension for implementing `Outstanding` protocol.
  """

  use Spark.Dsl.Extension,
    sections: [AshOutstanding.Extension.section(Ash.Resource)],
    transformers: [AshOutstanding.Resource.Transformer]
end
