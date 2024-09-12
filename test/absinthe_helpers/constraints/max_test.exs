defmodule AbsintheHelpers.Constraints.MaxTest do
  use ExUnit.Case, async: true

  alias AbsintheHelpers.Constraints.Max

  test "max constraint on integer" do
    input = %{data: 5}

    assert {:ok, %{data: 5}} = Max.call(input, {:max, 10})
    assert {:error, :max_exceeded, %{max: 3}} = Max.call(input, {:max, 3})
  end

  test "max constraint on string length" do
    input = %{data: "hello"}

    assert {:ok, %{data: "hello"}} = Max.call(input, {:max, 10})
    assert {:error, :max_exceeded, %{max: 3}} = Max.call(input, {:max, 3})
  end

  test "max constraint on decimal" do
    input = %{data: Decimal.new("5.00")}

    assert {:ok, %{data: %Decimal{}}} = Max.call(input, {:max, 10})
    assert {:error, :max_exceeded, %{max: 3}} = Max.call(input, {:max, 3})
  end
end
