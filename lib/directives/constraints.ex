defmodule AbsintheHelpers.Directives.Constraints do
  @moduledoc """
  Defines a GraphQL directive for adding constraints to fields and arguments.

  Supports:
  - `:min`, `:max`: For numbers and string lengths
  - `:min_items`, `:max_items`: For lists

  Applicable to scalars (:string, :integer, :float, :decimal) and lists.

  Example:
      field :username, :string, directives: [constraints: [min: 3, max: 20]]
      arg :tags, list_of(:string), directives: [constraints: [max_items: 5, max: 10]]

  Constraints are automatically enforced during query execution.
  """

  use Absinthe.Schema.Prototype

  alias Absinthe.Blueprint.TypeReference.{List, NonNull}

  @constraints %{
    string: [:min, :max],
    number: [:min, :max],
    list: [:min, :max, :min_items, :max_items]
  }

  directive :constraints do
    on([:argument_definition, :field_definition])

    arg(:min, :integer, description: "Minimum value allowed")
    arg(:max, :integer, description: "Maximum value allowed")
    arg(:min_items, :integer, description: "Minimum number of items allowed in a list")
    arg(:max_items, :integer, description: "Maximum number of items allowed in a list")

    expand(&__MODULE__.expand_constraints/2)
  end

  def expand_constraints(args, node = %{type: type}) do
    do_expand(args, node, get_args(type))
  end

  defp get_args(:string), do: @constraints.string
  defp get_args(type) when type in [:integer, :float, :decimal], do: @constraints.number
  defp get_args(%List{}), do: @constraints.list
  defp get_args(%NonNull{of_type: of_type}), do: get_args(of_type)
  defp get_args(type), do: raise(ArgumentError, "Unsupported type: #{inspect(type)}")

  defp do_expand(args, node, allowed_args) do
    {valid_args, invalid_args} = Map.split(args, allowed_args)
    handle_invalid_args(node, invalid_args)
    update_node(valid_args, node)
  end

  defp handle_invalid_args(_, args) when map_size(args) == 0, do: :ok

  defp handle_invalid_args(%{type: type, name: name, __reference__: reference}, invalid_args) do
    args = Map.keys(invalid_args)
    location_line = get_in(reference, [:location, :line])

    raise Absinthe.Schema.Error,
      phase_errors: [
        %Absinthe.Phase.Error{
          phase: __MODULE__,
          message:
            "Invalid constraints for field/arg `#{name}` of type `#{inspect(type)}`: #{inspect(args)}",
          locations: [%{line: location_line, column: 0}]
        }
      ]
  end

  defp update_node(args, node) do
    %{node | __private__: Keyword.put(node.__private__, :constraints, args)}
  end
end
