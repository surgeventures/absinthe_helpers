defmodule AbsintheHelpers.Constraints.MinItemsTest do
  use ExUnit.Case, async: true

  alias AbsintheHelpers.Constraints.MinItems

  test "min_items constraint on list" do
    input = %{
      items: [
        %{data: 1},
        %{data: 2},
        %{data: 3}
      ]
    }

    assert MinItems.call(input, {:min_items, 2}) == {:ok, input}
    assert MinItems.call(input, {:min_items, 5}) == {:error, :min_items_not_met, %{min_items: 5}}
  end

  test "min_items constraint on non-list input" do
    input = %{data: "not a list"}

    assert MinItems.call(input, {:min_items, 2}) == {:ok, input}
  end
end
