defmodule AbsintheHelpers.Transforms.Increment do
  alias Absinthe.Blueprint.Input

  @behaviour AbsintheHelpers.Transform

  def call(%Input.Value{data: data} = item, [step]) do
    {:ok, %{item | data: data + step}}
  end
end
