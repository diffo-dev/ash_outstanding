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

  describe "specification resource" do
    defresource Specification do
      outstanding do
        expect [:name, :major_version, :version]
        #include [:id]
      end
    end

    test "name" do
      expected = %Specification{id: @expected_id, name: "access"}
      actual_access =  %Specification{id: @actual_id, name: "access"}
      actual_transport =  %Specification{id: @actual_id, name: "transport_"}
      IO.inspect(outstanding(expected, nil), label: "test name outstanding")
      assert outstanding?(expected, nil)
      assert nil_outstanding?(expected, actual_access)
      assert expected >>> actual_transport
      IO.inspect(expected --- actual_transport, label: "test name outstanding")
    end

    test "name and major version" do
      assert outstanding?(%Specification{id: @expected_id, name: "access", major_version: 1}, nil)
      assert nil_outstanding?(%Specification{id: @expected_id, name: "access", major_version: 1}, %Specification{id: @actual_id, name: "access", major_version: 1})
      assert %Specification{id: @expected_id, name: "access", major_version: 1} >>> %Specification{id: @actual_id, name: "access", major_version: 2}
      IO.inspect(%Specification{id: @expected_id, name: "access", major_version: 1} --- %Specification{id: @actual_id, name: "access", major_version: 2}, label: "test name and version outstanding")
    end

    test "name and version regex" do
      #assert outstanding(%Specification{id: @expected_id, name: "access", version: ~r/v1.1/}, %Specification{id: @actual_id, name: "access", version: "v1.2.0"} == %Specification{id: @expected_id, version: ~r/v1.1/})
      assert outstanding?(%Specification{id: @expected_id, version: ~r/v1.1/}, nil)
      assert nil_outstanding?(%Specification{id: @expected_id, version: ~r/v1.1/}, %Specification{id: @actual_id, version: "v1.1.17"})
      assert %Specification{id: @expected_id, version: ~r/v1.1/} >>> %Specification{id: @actual_id, version: "v1.2.0"}
      IO.inspect(%Specification{id: @expected_id, version: ~r/v1.1/} --- %Specification{id: @actual_id, version: "v1.2.0"}, label: "test name and version regex outstanding")
    end
  end
end
