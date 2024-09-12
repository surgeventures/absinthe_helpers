defmodule AbsintheHelpers.Transforms.ToInteger do
  @moduledoc """
  A transformation that converts string input values to integers in an Absinthe
  schema.

  Add the transformation in your schema:

      alias AbsintheHelpers.Transforms.ToInteger

      field :employee_id, :id do
        meta transforms: [ToInteger]
      end
  """

  @behaviour AbsintheHelpers.Transform

  def call(%{data: data} = item, _opts) when is_binary(data) do
    case Integer.parse(data) do
      {int, ""} -> {:ok, %{item | data: int}}
      _ -> {:error, :invalid_integer, %{}}
    end
  end

  def call(%{data: _data}, _opts), do: {:error, :invalid_integer, %{}}
end
