defmodule AshOutstanding.Transformer do
  @moduledoc false

  use Spark.Dsl.Transformer

  defmodule Step do
    @moduledoc false

    defstruct [:type, :input]
  end

  def transform(dsl) do
    dsl =
      Spark.Dsl.Transformer.eval(
        dsl,
        [],
        quote do
          defimpl Outstanding do
            def outstanding(expected, actual) do
              expected_map = Map.take(expected, unquote(expect(dsl)))
              case {expected, actual} do
                {%name{}, nil} ->
                  expected_map |> Outstand.map_to_struct(name)
                {%name{}, _} ->
                  Outstanding.outstanding(expected_map, Map.from_struct(actual))
                  |> Outstand.map_to_struct(name)
              end
            end
          end
        end
      )

    {:ok, dsl}
  end

  def expect(dsl) do
    case Spark.Dsl.Transformer.get_option(dsl, [:outstanding], :expect, %{}) do
      keys when is_list(keys) ->
        keys
      key when is_atom(key) ->
        [key]
    end
  end
end
