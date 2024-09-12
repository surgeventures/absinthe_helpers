defmodule AbsintheHelpers.Transforms.Increment do
  @moduledoc false

  alias Absinthe.Blueprint.Input

  @behaviour AbsintheHelpers.Transform

  def call(item = %Input.Value{data: data}, [step]) do
    {:ok, %{item | data: data + step}}
  end
end
