defmodule AbsintheHelpers.Constraints.MinTest do
  use ExUnit.Case, async: true

  alias AbsintheHelpers.Constraints.Min

  test "min constraint on integer" do
    input = %{data: 5}

    assert Min.call(input, {:min, 3}) == {:ok, input}
    assert Min.call(input, {:min, 10}) == {:error, :min_not_met, %{min: 10}}
  end

  test "min constraint on string length" do
    input = %{data: "hello"}

    assert Min.call(input, {:min, 3}) == {:ok, input}
    assert Min.call(input, {:min, 10}) == {:error, :min_not_met, %{min: 10}}
  end

  test "min constraint on decimal" do
    input = %{data: Decimal.new("5.0")}

    assert Min.call(input, {:min, 3}) == {:ok, input}
    assert Min.call(input, {:min, 10}) == {:error, :min_not_met, %{min: 10}}
  end
end
