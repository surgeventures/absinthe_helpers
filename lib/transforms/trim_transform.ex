defmodule AbsintheHelpers.Transforms.TrimTransform do
  @moduledoc """
  A transformation that trims whitespace from string input values in an Absinthe
  schema.

  ## Example Usage

  Add the transformation to a field in your schema:

      field :username, :string do
        meta transforms: [:trim]
      end
  """

  alias Absinthe.Blueprint.Input

  @behaviour AbsintheHelpers.Transform

  def call(%Input.Value{data: data} = item, _opts) when is_binary(data) do
    {:ok, %{item | data: String.trim(data)}}
  end

  def call(_, _), do: {:error, :invalid_value}
end
