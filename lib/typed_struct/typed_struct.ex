# SPDX-FileCopyrightText: 2025 ash_outstanding contributors <https://github.com/diffo-dev/ash_outstanding/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshOutstanding.TypedStruct do
  @moduledoc """
  `Ash.TypedStruct` extension for implementing `Outstanding` protocol.
  """

  use Spark.Dsl.Extension,
    sections: [AshOutstanding.Extension.section(Ash.TypedStruct)],
    transformers: [AshOutstanding.TypedStruct.Transformer]
end
