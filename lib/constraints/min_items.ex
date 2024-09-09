defmodule AbsintheHelpers.Constraints.MinItems do
  @moduledoc false

  @behaviour AbsintheHelpers.Constraint

  def call(node = %{items: items}, {:min_items, min_items}) do
    if Enum.count(items) < min_items do
      {:error, :min_items_not_met, %{min_items: min_items, items: Enum.map(items, & &1.data)}}
    else
      {:ok, node}
    end
  end

  def call(node, {:min_items, _min_items}) do
    {:ok, node}
  end
end
