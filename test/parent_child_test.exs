defmodule ParentChildTest do
  @moduledoc false
  use ExUnit.Case

  describe "parent child expectations" do
    test "parent child expectations - outstanding child" do
      expected_parent = Generator.generate(Generator.service(name: :expected_parent, state: :active, status: :working))
      expected_child = Generator.generate(Generator.service(name: :expected_child, state: :active, status: :working))

      expected =
        expected_parent
        |> Ash.Changeset.for_update(:update, add_child: [expected_child.id])
        |> Ash.update!()
        |> Ash.load!([:children])

      actual =
        Generator.generate(Generator.service(name: :actual_parent, state: :active, status: :working))
        |> Ash.load!([:children])

      outstanding = Outstanding.outstanding(expected, actual)
      assert Outstanding.outstanding?(expected, actual) == true
      assert outstanding.state == nil
      assert outstanding.status == nil
      refute outstanding.children == nil
      outstanding_child = hd(outstanding.children)
      assert outstanding_child.state == :active
      assert outstanding_child.status == :working
      assert outstanding_child == Ash.Test.strip_metadata(%Service{state: :active, status: :working})
    end

    test "parent child expectations - outstanding, child status" do
      expected_parent = Generator.generate(Generator.service(name: :expected_parent, state: :active, status: :working))
      expected_child = Generator.generate(Generator.service(name: :expected_child, state: :active, status: :working))

      expected =
        expected_parent
        |> Ash.Changeset.for_update(:update, add_child: [expected_child.id])
        |> Ash.update!()
        |> Ash.load!([:children])

      actual_parent = Generator.generate(Generator.service(name: :actual_parent, state: :active, status: :working))

      actual_child =
        Generator.generate(Generator.service(name: :actual_child, state: :active, status: :failed))
        |> Ash.load!([:children])

      actual =
        actual_parent
        |> Ash.Changeset.for_update(:update, add_child: [actual_child.id])
        |> Ash.update!()
        |> Ash.load!([:children])

      assert Outstanding.outstanding?(expected, actual) == true
      outstanding = Outstanding.outstanding(expected, actual)
      refute outstanding.children == nil
      outstanding_child = hd(outstanding.children)
      assert outstanding_child.state == nil
      assert outstanding_child.status == :working
      assert outstanding_child == Ash.Test.strip_metadata(%Service{status: :working})
    end

    test "parent child expecations - resolved" do
      expected_parent = Generator.generate(Generator.service(name: :expected_parent, state: :active, status: :working))
      expected_child = Generator.generate(Generator.service(name: :expected_child, state: :active, status: :working))

      expected =
        expected_parent
        |> Ash.Changeset.for_update(:update, add_child: [expected_child.id])
        |> Ash.update!()
        |> Ash.load!([:children])

      actual_parent = Generator.generate(Generator.service(name: :actual_parent, state: :active, status: :working))

      actual_child =
        Generator.generate(Generator.service(name: :actual_child, state: :active, status: :working))
        |> Ash.load!([:children])

      actual =
        actual_parent
        |> Ash.Changeset.for_update(:update, add_child: [actual_child.id])
        |> Ash.update!()
        |> Ash.load!([:children])

      assert Outstanding.outstanding?(expected, actual) == false
      assert Outstanding.outstanding(expected, actual) == nil
    end
  end
end
