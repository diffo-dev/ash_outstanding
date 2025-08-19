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
                    expected_map |> Outstand.map_to_struct(name) |> Ash.Test.strip_metadata()

                  {%name{}, _} ->
                    Outstanding.outstanding(expected_map, Map.from_struct(actual))
                    |> Outstand.map_to_struct(name)
                    |> Ash.Test.strip_metadata()
                end

              unquote_splicing(make_steps(dsl))
            end

            def outstanding?(expected, actual) do
              Outstanding.outstanding(expected, actual) != nil
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

      options when is_map(options) ->
        fields = Ash.Resource.Info.fields(dsl)
        fields = if Map.get(options, :private?), do: fields, else: Enum.filter(fields, & &1.public?)
        fields = if Map.get(options, :sensitive?), do: fields, else: Enum.reject(fields, &Map.get(&1, :sensitive?))
        keys = Enum.map(fields, & &1.name)
        keys = keys ++ Map.get(options, :include, [])
        keys = Enum.uniq(keys)
        keys = keys -- Map.get(options, :exclude, [])
        keys
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
