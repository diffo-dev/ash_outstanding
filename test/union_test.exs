# SPDX-FileCopyrightText: 2025 ash_outstanding contributors <https://github.com/diffo-dev/ash_outstanding/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshOutstanding.Union.Test do
  use ExUnit.Case

  use Outstand
  import AshOutstanding.Union

  describe "union" do
    test "Ash.Union implements Outstanding" do
      expected = %Ash.Union{type: :string, value: "connectivity"}
      assert Outstanding.impl_for(expected) == Outstanding.Ash.Union
    end

    test "expected string is outstanding, actual is nil" do
      expected = %Ash.Union{type: :string, value: "connectivity"}
      actual = nil
      assert expected --- actual == expected
      assert expected >>> actual == true
    end

    test "expected string is outstanding, actual is union with nil string" do
      expected = %Ash.Union{type: :string, value: "connectivity"}
      actual = %Ash.Union{type: :string, value: nil}
      assert expected --- actual == expected
      assert expected >>> actual == true
    end

    test "expected function is outstanding, actual is union with nil string" do
      expected = %Ash.Union{type: :function, value: &any_bitstring/1}
      actual = %Ash.Union{type: :string, value: nil}
      assert expected --- actual == %Ash.Union{type: :atom, value: :any_bitstring}
      assert expected >>> actual == true
    end

    test "expected string is resolved" do
      expected = %Ash.Union{type: :string, value: "connectivity"}
      actual = %Ash.Union{type: :string, value: "connectivity"}
      assert expected --- actual == nil
      assert expected >>> actual == false
    end

    test "expected function is resolved" do
      expected = %Ash.Union{type: :function, value: &any_bitstring/1}
      actual = %Ash.Union{type: :string, value: "connectivity"}
      assert expected --- actual == nil
      assert expected >>> actual == false
    end
  end
end
