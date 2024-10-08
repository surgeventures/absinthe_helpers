defmodule AbsintheHelpers.Transforms.Trim do
  @moduledoc """
  A transformation that trims whitespace from string input values in an
  Absinthe schema.

  ## Example Usage

  Add the transformation to a field in your schema:

      alias AbsintheHelpers.Transforms.Trim

      field :username, :string do
        meta transforms: [Trim]
      end
  """

  @behaviour AbsintheHelpers.Transform

  def call(item = %{data: nil}, _opts), do: {:ok, item}

  def call(item = %{data: data}, _opts) when is_binary(data) do
    {:ok, %{item | data: String.trim(data)}}
  end

  def call(%{data: _data}, _), do: {:error, :invalid_value, %{}}
end
