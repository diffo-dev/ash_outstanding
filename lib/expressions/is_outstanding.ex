defmodule AshOutstanding.Expressions.IsOutstanding do
  use Ash.CustomExpression,
    name: :is_outstanding,
    arguments: [
      [:term, :term]
    ]

  def expression(data_layer, [expected, actual])
      when data_layer in [
             Ash.DataLayer.Ets,
             Ash.DataLayer.Simple
           ] do
    {:ok, expr(fragment(&__MODULE__.is_outstanding/2, ^expected, ^actual))}
  end

  def expression(_data_layer, _args), do: :unknown

  @doc "Computes is_outstanding on two terms using Outstanding protocol"
  def is_outstanding(expected, actual) do
    Outstanding.outstanding?(expected, actual)
  end
end
