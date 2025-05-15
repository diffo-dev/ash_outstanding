defmodule AshOutstanding.Union do
  @moduledoc """
  Outstanding protocol implementation for Ash.Union :type_and_value.
  """

  use Outstand

  defoutstanding expected :: Ash.Union, actual :: Any do
    case Outstand.type_of(actual) do
      Ash.Union ->
        outstanding = Outstanding.outstanding(expected.value, actual.value)

        if outstanding == nil do
          nil
        else
          if expected.type == :function && is_atom(outstanding) do
            %Ash.Union{type: :atom, value: outstanding}
          else
            %Ash.Union{type: expected.type, value: outstanding}
          end
        end

      _ ->
        expected
    end
  end
end
