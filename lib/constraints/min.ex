defmodule AbsintheHelpers.Constraints.Min do
  @moduledoc false

  @behaviour AbsintheHelpers.Constraint

  def call(node = %{items: _items}, {:min, _min}) do
    {:ok, node}
  end

  def call(node = %{data: data = %Decimal{}}, {:min, min}) do
    if is_integer(min) and Decimal.lt?(data, min),
      do: {:error, :min_not_met, %{min: min}},
      else: {:ok, node}
  end

  def call(node = %{data: data}, {:min, min}) when is_binary(data) do
    if String.length(data) < min,
      do: {:error, :min_not_met, %{min: min}},
      else: {:ok, node}
  end

  def call(node = %{data: data}, {:min, min}) do
    if data < min,
      do: {:error, :min_not_met, %{min: min}},
      else: {:ok, node}
  end
end
