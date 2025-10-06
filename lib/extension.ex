defmodule AshOutstanding.Extension do
  @moduledoc false

  def section(target) do

    customize_entity = %Spark.Dsl.Entity{
      name: :customize,
      describe: """
        A step to arbitrary customize outstanding
      """,
      target: AshOutstanding.TransformerHelper.Step,
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

    expect_options =
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
            ]

    expect_options =
      if target == Ash.TypedStruct do
        Keyword.take(expect_options, [:include, :exclude])
      else
        expect_options
      end

    outstanding_section = %Spark.Dsl.Section{
      name: :outstanding,
      describe: """
        Configuration for Outstanding implementation.
      """,
      schema: [
        expect: [
          doc: """
            Keys to expect in outstanding calculation. Accepts a single key or list of keys, where keys are atoms, or a behaviour configuration map.
          """,
          type: {:or, [:atom, {:list, :atom}, {:map, expect_options}]}
        ]
      ],
      entities: [
        customize_entity
      ]
    }

    outstanding_section
  end
end
