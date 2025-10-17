# SPDX-FileCopyrightText: 2025 ash_outstanding contributors <https://github.com/diffo-dev/ash_outstanding/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshOutstanding.TypedStruct.Transformer do
  @moduledoc false

  use Spark.Dsl.Transformer

  @impl true
  def transform(dsl) do
    AshOutstanding.TransformerHelper.transform(dsl, fn dsl, _options ->
      fields = Ash.TypedStruct.Info.fields(dsl)
      fields
    end)
  end
end
