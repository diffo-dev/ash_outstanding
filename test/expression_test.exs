defmodule ExpressionTest do
  @moduledoc false
  use ExUnit.Case

  describe "calculations" do
    test "specification expects major version 2 - outstanding" do
      specification = Generator.generate(Generator.specification(name: :access, major_version: 1))
      assert Ash.calculate!(specification, :is_outstanding_major_version) == true
      assert Ash.calculate!(specification, :outstanding_major_version) == 2
    end

    test "specification expects major version 2 - resolved" do
      specification = Generator.generate(Generator.specification(name: :access, major_version: 2))
      assert Ash.calculate!(specification, :is_outstanding_major_version) == false
      assert Ash.calculate!(specification, :outstanding_major_version) == nil
    end
  end
end
