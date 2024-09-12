defmodule AbsintheHelpers.Constraints.MaxItemsTest do
  use ExUnit.Case, async: true

  alias AbsintheHelpers.Constraints.MaxItems

  test "max_items constraint on list" do
    input = %{
      items: [
        %{data: 1},
        %{data: 2},
        %{data: 3}
      ]
    }

    assert MaxItems.call(input, {:max_items, 5}) == {:ok, input}
    assert MaxItems.call(input, {:max_items, 2}) == {:error, :max_items_exceeded, %{max_items: 2}}
  end

  test "max_items constraint on non-list input" do
    input = %{data: "not a list"}

    assert MaxItems.call(input, {:max_items, 2}) == {:ok, input}
  end
end
