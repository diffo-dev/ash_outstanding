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

    resource Service do
      define :create_service, action: :create
      define :update_service, action: :update
      define :read_service, action: :read
      define :destroy_service, action: :destroy
    end
  end
end
