defmodule AbsintheHelpers.Constraints.Regex do
  @moduledoc """
  Applies regex constraint on node data only when the data is binary.
  """

  @behaviour AbsintheHelpers.Constraint

  def call(node = %{items: _items}, {:regex, _min}) do
    {:ok, node}
  end

  def call(node = %{data: data}, {:regex, regex}) when is_binary(data) do
    if data =~ regex do
      {:ok, node}
    else
      {:error, :invalid_format, %{regex: regex}}
    end
  end
end
