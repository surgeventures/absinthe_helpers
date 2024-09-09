defmodule AbsintheHelpers.Transforms.ToIntegerTransform do
  @moduledoc """
  A transformation that converts string input values to integers in an Absinthe
  schema.

  Add the transformation in your schema:

      field :employee_id, :id do
        meta transforms: [:to_integer]
      end
  """

  alias Absinthe.Blueprint.Input

  @behaviour AbsintheHelpers.Transform

  def call(%Input.Value{data: data} = item, _opts) when is_binary(data) do
    case Integer.parse(data) do
      {int, ""} -> {:ok, %{item | data: int}}
      _ -> {:error, :invalid_integer}
    end
  end

  def call(_item, _opts), do: {:error, :invalid_integer}
end
