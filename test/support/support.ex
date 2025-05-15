defmodule Specification do
  use Ash.Resource,
    domain: Domain,
    data_layer: Ash.DataLayer.Ets,
    extensions: [AshOutstanding.Resource]

  outstanding do
    expect([:name, :major_version])
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  code_interface do
    define :create, action: :create
    define :read, action: :read
  end

  attributes do
    uuid_primary_key :id, writable?: true
    attribute :href, :string, public?: true
    attribute :name, :string, public?: true
    attribute :major_version, :integer, public?: true
    attribute :version, :string, public?: true

    attribute :category, :union do
      constraints types: [
                    string: [type: :string],
                    atom: [type: :atom],
                    function: [type: :function]
                  ]
    end
  end

  calculations do
    calculate :is_outstanding_major_version, :boolean, expr(is_outstanding(2, major_version))
    calculate :outstanding_major_version, :term, expr(outstanding(2, major_version))
  end
end

defmodule Domain do
  @moduledoc false
  use Ash.Domain,
    validate_config_inclusion?: false

  resources do
    resource Specification do
      define :create_specification, action: :create
      define :update_specification, action: :update
      define :read_specification, action: :read
      define :destroy_specification, action: :destroy
    end
  end
end

2
