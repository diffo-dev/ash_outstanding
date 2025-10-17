# SPDX-FileCopyrightText: 2025 ash_outstanding contributors <https://github.com/diffo-dev/ash_outstanding/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshOutstanding.Test.Macros do
  defmacro defresource(name, block) do
    quote do
      defmodule unquote(name) do
        use Ash.Resource,
          domain: nil,
          validate_domain_inclusion?: false,
          data_layer: Ash.DataLayer.Ets,
          extensions: [AshOutstanding.Resource]

        attributes do
          uuid_primary_key :id, writable?: true
          attribute :href, :string, public?: true
          attribute :name, :string, public?: true
          attribute :major_version, :integer, public?: false
          attribute :minor_version, :integer, public?: false
          attribute :version, :string, public?: true
          attribute :password, :string, sensitive?: true

          attribute :category, :union do
            constraints types: [
                          string: [type: :string],
                          atom: [type: :atom],
                          function: [type: :function]
                        ]
          end
        end

        unquote(block)
      end
    end
  end

  defmacro deftypedstruct(name, block) do
    quote do
      defmodule unquote(name) do
        use Ash.TypedStruct,
          extensions: [AshOutstanding.TypedStruct]

        typed_struct do
          field :id, :uuid

          field :href, :string
          field :name, :string
          field :major_version, :integer
          field :minor_version, :integer
          field :version, :string
        end

        unquote(block)
      end
    end
  end
end

defmodule AshOutstanding.Test do
  use ExUnit.Case
  import Outstand
  import Outstanding

  import AshOutstanding.Test.Macros

  @expected_id "e3130919-6fef-4a5f-a46e-62522f0d424b"
  @actual_id "a7e8e60e-54f5-4009-b53d-c0bd2795c81c"

  describe "minimal dsl" do
    defresource Minimal do
    end

    test "name" do
      expected = %Minimal{name: "access"}
      actual_realizing = %Minimal{name: "access"}
      actual_outstanding = %Minimal{name: "transport"}
      refute outstanding?(expected, actual_realizing)
      assert outstanding?(expected, nil)
      assert expected >>> actual_outstanding
      assert outstanding(expected, nil) == Ash.Test.strip_metadata(expected)
      assert expected --- actual_outstanding == Ash.Test.strip_metadata(expected)
    end
  end

  describe "expect" do
    defresource ExpectOnly do
      outstanding do
        expect([:name])
      end
    end

    test "name" do
      expected = %ExpectOnly{name: "access"}
      actual_realizing = %ExpectOnly{name: "access"}
      actual_outstanding = %ExpectOnly{name: "transport"}
      refute outstanding?(expected, actual_realizing)
      assert outstanding?(expected, nil)
      assert expected >>> actual_outstanding
      assert outstanding(expected, nil) == Ash.Test.strip_metadata(expected)
      assert expected --- actual_outstanding == Ash.Test.strip_metadata(expected)
    end

    test "name where actual lacks __meta__" do
      expected = Kernel.struct(ExpectOnly, name: "access")
      actual_realizing = %ExpectOnly{name: "access"} |> Map.put(:__meta__, nil)
      actual_outstanding = %ExpectOnly{name: "transport"} |> Map.put(:__meta__, nil)
      refute outstanding?(expected, actual_realizing)
      assert outstanding?(expected, nil)
      assert expected >>> actual_outstanding
      assert outstanding(expected, nil) == Ash.Test.strip_metadata(expected)
      assert expected --- actual_outstanding == Ash.Test.strip_metadata(expected)
    end
  end

  describe "expect all fields" do
    defresource ExpectAllFields do
      outstanding do
        expect(%{sensitive?: true, private?: true})
      end
    end

    test "includes private" do
      assert outstanding?(%ExpectAllFields{major_version: 1, minor_version: 1}, %ExpectAllFields{
               major_version: 2,
               minor_version: 0
             })
    end

    test "includes sensitive" do
      assert outstanding?(%ExpectAllFields{password: &Outstand.any_bitstring/1}, %ExpectAllFields{password: nil})
    end
  end

  describe "expect include and exclude" do
    defresource ExpectSpecific do
      outstanding do
        expect(%{include: [:major_version, :minor_version], exclude: [:version]})
      end
    end

    test "includes specific" do
      assert outstanding?(%ExpectSpecific{major_version: 1, minor_version: 0}, %ExpectSpecific{
               major_version: 2,
               minor_version: 0
             })
    end

    test "excludes specific" do
      refute outstanding?(%ExpectSpecific{version: "v1.1"}, %ExpectSpecific{version: "v1.0"})
    end
  end

  describe "customize" do
    defresource WithCustomize do
      outstanding do
        expect([:name, :major_version, :version])

        customize fn outstanding, expected, _actual ->
          case outstanding do
            nil ->
              outstanding

            %_{} ->
              outstanding
              |> Map.put(:id, expected.id)
          end
        end
      end
    end

    test "name" do
      expected = %WithCustomize{id: @expected_id, name: "access"}
      actual_realizing = %WithCustomize{id: @actual_id, name: "access"}
      actual_outstanding = %WithCustomize{id: @actual_id, name: "transport"}
      refute outstanding?(expected, actual_realizing)
      assert outstanding?(expected, nil)
      assert expected >>> actual_outstanding
      assert outstanding(expected, nil) == Ash.Test.strip_metadata(expected)
      assert expected --- actual_outstanding == Ash.Test.strip_metadata(expected)
    end

    test "name and major version" do
      expected = %WithCustomize{id: @expected_id, name: "access", major_version: 1}
      actual_realizing = %WithCustomize{id: @actual_id, name: "access", major_version: 1}
      actual_outstanding = %WithCustomize{id: @actual_id, name: "transport", major_version: 2}
      refute outstanding?(expected, actual_realizing)
      assert outstanding(expected, nil)
      assert expected >>> actual_outstanding
      assert outstanding(expected, actual_outstanding) == Ash.Test.strip_metadata(expected)
      assert expected --- actual_outstanding == Ash.Test.strip_metadata(expected)
    end

    test "name and version regex" do
      version_regex = ~r/v1.1/
      expected = %WithCustomize{id: @expected_id, name: "access", version: version_regex}
      actual_realizing = %WithCustomize{id: @actual_id, name: "access", version: "v1.1.17"}
      actual_outstanding = %WithCustomize{id: @actual_id, name: "access", version: "v1.2.0"}
      refute outstanding?(expected, actual_realizing)
      assert outstanding?(expected, nil)
      assert expected >>> actual_outstanding

      assert outstanding(expected, actual_outstanding) ==
               Ash.Test.strip_metadata(%WithCustomize{id: @expected_id, version: version_regex})

      assert expected --- actual_outstanding ==
               Ash.Test.strip_metadata(%WithCustomize{id: @expected_id, version: version_regex})
    end
  end

  describe "union" do
    import AshOutstanding.Union

    defresource WithExpectCategory do
      outstanding do
        expect([:name, :category])
      end
    end

    test "expected category is string" do
      expected = %WithExpectCategory{name: nil, category: %Ash.Union{type: :string, value: "connectivity"}}
      actual_realizing = %WithExpectCategory{name: "access", category: %Ash.Union{type: :string, value: "connectivity"}}
      actual_outstanding = %WithExpectCategory{category: %Ash.Union{type: :string, value: "value added"}}
      outstanding = outstanding(expected, actual_realizing)
      assert outstanding == nil
      assert outstanding?(expected, nil)
      assert expected >>> actual_outstanding
      assert outstanding(expected, nil) == Ash.Test.strip_metadata(expected)
      assert expected --- actual_outstanding == Ash.Test.strip_metadata(expected)
    end

    test "expected category is function" do
      expected = %WithExpectCategory{name: nil, category: %Ash.Union{type: :function, value: &Outstand.any_bitstring/1}}
      actual_realizing = %WithExpectCategory{name: "access", category: %Ash.Union{type: :string, value: "connectivity"}}
      actual_outstanding = %WithExpectCategory{category: %Ash.Union{type: :string, value: nil}}

      outstanding = outstanding(expected, actual_realizing)
      assert outstanding == nil
      assert outstanding?(expected, nil)
      assert expected >>> actual_outstanding
      assert outstanding(expected, nil) == Ash.Test.strip_metadata(expected)

      assert expected --- actual_outstanding ==
               Ash.Test.strip_metadata(%WithExpectCategory{
                 category: %Ash.Union{type: :atom, value: :any_bitstring}
               })
    end
  end

  describe "typed struct extension" do
    deftypedstruct StructWithCustomize do
      outstanding do
        expect([:name, :major_version, :version])

        customize fn outstanding, expected, _actual ->
          case outstanding do
            nil ->
              outstanding

            %_{} ->
              outstanding
              |> Map.put(:id, expected.id)
          end
        end
      end
    end

    deftypedstruct StructExpectSpecific do
      outstanding do
        expect(%{include: [:major_version, :minor_version], exclude: [:version]})
      end
    end

    test "includes specific" do
      assert outstanding?(%StructExpectSpecific{major_version: 1, minor_version: 0}, %StructExpectSpecific{
               major_version: 2,
               minor_version: 0
             })
    end

    test "excludes specific" do
      refute outstanding?(%StructExpectSpecific{version: "v1.1"}, %StructExpectSpecific{version: "v1.0"})
    end

    test "customize" do
      expected = %StructWithCustomize{id: @expected_id, name: "access", major_version: 1}
      actual_realizing = %StructWithCustomize{id: @actual_id, name: "access", major_version: 1}
      actual_outstanding = %StructWithCustomize{id: @actual_id, name: "transport", major_version: 2}
      refute outstanding?(expected, actual_realizing)
      assert outstanding(expected, nil)
      assert expected >>> actual_outstanding
      assert outstanding(expected, actual_outstanding) == Ash.Test.strip_metadata(expected)
      assert expected --- actual_outstanding == Ash.Test.strip_metadata(expected)
    end
  end
end
