# SPDX-FileCopyrightText: 2025 ash_outstanding contributors <https://github.com/diffo-dev/ash_outstanding/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Generator do
  use Ash.Generator

  def specification(opts \\ []) do
    changeset_generator(
      Specification,
      :create,
      overrides: opts,
      actor: opts[:actor]
    )
  end

  def service(opts \\ []) do
    changeset_generator(
      Service,
      :create,
      overrides: opts,
      actor: opts[:actor]
    )
  end
end
