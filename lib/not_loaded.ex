# SPDX-FileCopyrightText: 2025 ash_outstanding contributors <https://github.com/diffo-dev/ash_outstanding/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshOutstanding.NotLoaded do
  @moduledoc """
  Outstanding protocol implementation for Ash.NotLoaded
  """

  use Outstand

  defoutstanding expected :: Ash.NotLoaded, actual :: Any do
    # shut up dialyzer, can't put _expected and _actual due to macro, but don't need to evaluate them here
    expected && actual
    nil
  end
end
