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
              expected_map = Map.take(expected, unquote(make_expect(dsl)))
              outstanding =
                case {expected, actual} do
                  {%name{}, nil} ->
                    expected_map |> Outstand.map_to_struct(name)
                  {%name{}, _} ->
                    Outstanding.outstanding(expected_map, Map.from_struct(actual))
                    |> Outstand.map_to_struct(name)
                end
              unquote_splicing(make_steps(dsl))
            end
          end
        end
      )

    {:ok, dsl}
  end

  def make_expect(dsl) do
    case Spark.Dsl.Transformer.get_option(dsl, [:outstanding], :expect, %{}) do
      keys when is_list(keys) ->
        keys
      key when is_atom(key) ->
        [key]
    end
  end

  def make_steps(dsl) do
    for step <- Spark.Dsl.Transformer.get_entities(dsl, [:outstanding]),
        step_expression = make_step(step.type, step.input) do
      step_expression
    end
  end

  def make_step(:customize, fun) do
    quote bind_quoted: [fun: Macro.escape(fun)] do
      outstanding = fun.(outstanding, expected, actual)
    end
  end
end
