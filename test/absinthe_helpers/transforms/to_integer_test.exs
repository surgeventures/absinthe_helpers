defmodule AbsintheHelpers.Transforms.ToIntegerTest do
  use ExUnit.Case, async: true

  alias AbsintheHelpers.Transforms.ToInteger

  test "to_integer transformation on valid string" do
    input = %{data: "123"}

    assert {:ok, %{data: 123}} = ToInteger.call(input, [])
  end

  test "to_integer transformation on invalid string" do
    input = %{data: "abc"}

    assert ToInteger.call(input, []) == {:error, :invalid_integer, %{}}
  end

  test "to_integer transformation on non-string" do
    input = %{data: 123}

    assert ToInteger.call(input, []) == {:error, :invalid_integer, %{}}
  end
end
