defmodule AshOutstanding.Expressions.Outstanding do
  use Ash.CustomExpression,
    name: :outstanding,
    arguments: [
      [:term, :term]
    ]

  def expression(data_layer, [expected, actual])
      when data_layer in [
             Ash.DataLayer.Ets,
             Ash.DataLayer.Simple,
             AshNeo4j.DataLayer,
             AshCsv.DataLayer
           ] do
    {:ok, expr(fragment(&__MODULE__.outstanding/2, ^expected, ^actual))}
  end

  def expression(_data_layer, _args), do: :unknown

  @doc "Computes outstanding on two terms using Outstanding protocol"
  def outstanding(expected, actual) do
    Outstanding.outstanding(expected, actual)
  end
end
