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
          attribute :major_version, :integer, public?: true
          attribute :version, :string, public?: true
        end

        unquote(block)
      end
    end
  end
end

defmodule AshOutstanding.Test do
  use ExUnit.Case
  import Outstand
  import Outstanding, only: [outstanding: 2]

  import AshOutstanding.Test.Macros

  @expected_id "e3130919-6fef-4a5f-a46e-62522f0d424b"
  @actual_id "a7e8e60e-54f5-4009-b53d-c0bd2795c81c"

  describe "expect" do
    defresource ExpectOnly do
      outstanding do
        expect [:name]
      end
    end

    test "name" do
      expected = %ExpectOnly{name: "access"}
      actual_realizing = %ExpectOnly{name: "access"}
      actual_outstanding = %ExpectOnly{name: "transport"}
      refute outstanding?(expected, actual_realizing)
      assert outstanding?(expected, nil)
      assert expected >>> actual_outstanding
      assert outstanding(expected, nil) == expected
      assert expected --- actual_outstanding == expected
    end
  end

  describe "customize" do
    defresource WithCustomize do
      outstanding do
        expect [:name, :major_version, :version]
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
      assert outstanding(expected, nil) == expected
      assert expected --- actual_outstanding == expected
    end

    test "name and major version" do
      expected = %WithCustomize{id: @expected_id, name: "access", major_version: 1}
      actual_realizing = %WithCustomize{id: @actual_id, name: "access", major_version: 1}
      actual_outstanding = %WithCustomize{id: @actual_id, name: "transport", major_version: 2}
      refute outstanding?(expected, actual_realizing)
      assert outstanding(expected, nil)
      assert expected >>> actual_outstanding
      assert outstanding(expected, actual_outstanding) == expected
      assert expected --- actual_outstanding == expected
    end

    test "name and version regex" do
      expected = %WithCustomize{id: @expected_id, name: "access", version: ~r/v1.1/}
      actual_realizing = %WithCustomize{id: @actual_id, name: "access", version: "v1.1.17"}
      actual_outstanding = %WithCustomize{id: @actual_id, name: "access", version: "v1.2.0"}
      refute outstanding?(expected, actual_realizing)
      assert outstanding?(expected, nil)
      assert expected >>> actual_outstanding
      assert outstanding(expected, actual_outstanding) == %WithCustomize{id: @expected_id, version: ~r/v1.1/}
      assert expected --- actual_outstanding == %WithCustomize{id: @expected_id, version: ~r/v1.1/}
    end
  end
end
