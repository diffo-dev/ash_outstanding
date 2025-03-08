defmodule AshOutstanding.Resource do
  @moduledoc """
  Ash resource extension for implementing `Outstanding` protocol.
  """

  @outstanding %Spark.Dsl.Section{
    name: :outstanding,
    describe: """
      Configuration for Outstanding implementation.
    """,
    schema: [
      expect: [
        doc: """
          Keys to expect in outstanding calculation. Accepts a single key or list of keys, where keys are atoms.
        """,
        type:
         {:or, [:atom, {:list, :atom}]},
      ],
    ],
  }

  use Spark.Dsl.Extension,
    sections: [@outstanding],
    transformers: [AshOutstanding.Transformer]
end
