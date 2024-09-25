defmodule AbsintheHelpers.Transforms.TrimTest do
  use ExUnit.Case, async: true

  alias AbsintheHelpers.Transforms.Trim

  test "trim transformation on nil value" do
    input = %{data: nil}

    assert {:ok, %{data: nil}} = Trim.call(input, [])
  end

  test "trim transformation on string" do
    input = %{data: "  hello  "}

    assert {:ok, %{data: "hello"}} = Trim.call(input, [])
  end

  test "trim transformation on non-string" do
    input = %{data: 123}

    assert Trim.call(input, []) == {:error, :invalid_value, %{}}
  end
end
