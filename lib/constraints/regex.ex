defmodule AbsintheHelpers.Constraints.Regex do
  @moduledoc """
  Applies regex constraint on node data. This constraint can only be applied to String types.
  """

  @behaviour AbsintheHelpers.Constraint

  def call(node = %{data: data}, {:regex, regex}) do
    if data =~ regex do
      {:ok, node}
    else
      {:error, :invalid_format, %{regex: regex}}
    end
  end
end
