defmodule AbsintheHelpers.Constraints.RegexTest do
  use ExUnit.Case, async: true

  alias AbsintheHelpers.Constraints.Regex

  test "returns :ok tuple on regex match" do
    input = %{data: "username"}

    assert {:ok, %{data: "username"}} = Regex.call(input, {:regex, "^[a-z]*$"})
  end

  test "returns invalid_format error on regex match failure" do
    input = %{data: "user.name"}

    assert {:error, :invalid_format, %{regex: "^[a-z]*$"}} = Regex.call(input, {:regex, "^[a-z]*$"})
  end
end
