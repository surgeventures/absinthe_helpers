defmodule AbsintheHelpers.Constraints.MaxItems do
  @moduledoc false

  @behaviour AbsintheHelpers.Constraint

  def call(node = %{items: items}, {:max_items, max_items}) do
    if Enum.count(items) > max_items do
      {:error, :max_items_exceeded, %{max_items: max_items, items: Enum.map(items, & &1.data)}}
    else
      {:ok, node}
    end
  end

  def call(node, {:max_items, _max_items}) do
    {:ok, node}
  end
end
