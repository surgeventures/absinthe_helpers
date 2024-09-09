defmodule AbsintheHelpers.Constraints.Max do
  @moduledoc false

  @behaviour AbsintheHelpers.Constraint

  def call(node = %{items: _items}, {:max, _min}) do
    {:ok, node}
  end

  def call(node = %{data: data = %Decimal{}}, {:max, max}) do
    if is_integer(max) and Decimal.gt?(data, max),
      do: {:error, :max_exceeded, %{max: max, value: data}},
      else: {:ok, node}
  end

  def call(node = %{data: data}, {:max, max}) when is_binary(data) do
    if String.length(data) > max,
      do: {:error, :max_exceeded, %{max: max, value: data}},
      else: {:ok, node}
  end

  def call(node = %{data: data}, {:max, max}) do
    if data > max,
      do: {:error, :max_exceeded, %{max: max, value: data}},
      else: {:ok, node}
  end
end
