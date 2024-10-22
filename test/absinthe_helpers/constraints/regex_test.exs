defmodule AbsintheHelpers.Constraints.RegexTest do
  use ExUnit.Case, async: true

  alias AbsintheHelpers.Constraints.Regex

  test "regex constraint passes" do
    input = %{data: "username"}

    assert {:ok, %{data: "username"}} = Regex.call(input, {:regex, ~r/^[a-z]*$/})
  end

  test "regex constraint fails" do
    input = %{data: "user.name"}

    assert {:error, :invalid_format, %{regex: ~r/^[a-z]*$/}} = Regex.call(input, {:regex, ~r/^[a-z]*$/})
  end
end
