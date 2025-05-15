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
end
