defmodule AbsintheHelpers.Transform do
  @moduledoc false

  alias Absinthe.Blueprint.Input

  @callback call(Input.Value.t(), list()) :: {:ok, Input.Value.t()} | {:error, atom()}
end
