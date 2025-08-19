defmodule AshOutstanding.Resource do
  @moduledoc """
  Ash resource extension for implementing `Outstanding` protocol.
  """

  @customize %Spark.Dsl.Entity{
    name: :customize,
    describe: """
      A step to arbitrary customize outstanding
    """,
    target: AshOutstanding.Transformer.Step,
    auto_set_fields: [type: :customize],
    args: [:fun],
    schema: [
      fun: [
        doc: """
          A function to customize a result with. Receives a result and a resource record.
        """,
        type: {:fun, [:any, :any, :any], :any},
        as: :input,
        required: true
      ]
    ]
  }

  @expect_map {:map,
              [
                private?: [
                  doc: """
                    Whenever to pick private fields.
                  """,
                  type: :boolean,
                  default: false,
                ],
                sensitive?: [
                  doc: """
                    Whenever to pick sensitive fields.
                  """,
                  type: :boolean,
                  default: false,
                ],
                include: [
                  doc: """
                    Keys to pick. In addition to fields.
                  """,
                  type: {:list, :atom},
                ],
                exclude: [
                  doc: """
                    Keys not to pick.
                  """,
                  type: {:list, :atom},
                ],
              ]}

  @outstanding %Spark.Dsl.Section{
    name: :outstanding,
    describe: """
      Configuration for Outstanding implementation.
    """,
    schema: [
      expect: [
        doc: """
          Keys to expect in outstanding calculation. Accepts a single key or list of keys, where keys are atoms, or a behaviour configuration map.
        """,
        type: {:or, [:atom, {:list, :atom}, @expect_map]}
      ]
    ],
    entities: [
      @customize
    ]
  }

  use Spark.Dsl.Extension,
    sections: [@outstanding],
    transformers: [AshOutstanding.Transformer]
end
