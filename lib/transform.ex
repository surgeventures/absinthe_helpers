defmodule AbsintheHelpers.Transform do
  @moduledoc false

  alias Absinthe.Blueprint.Input

  @type error_reason :: atom()
  @type error_details :: map()

  @callback call(Input.Value.t(), list()) ::
              {:ok, Input.Value.t()} | {:error, error_reason(), error_details()}
end
