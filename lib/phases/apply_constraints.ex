defmodule AbsintheHelpers.Phases.ApplyConstraints do
  @moduledoc """
  Validates input nodes against constraints defined by the `constraints`
  directive in your Absinthe schema. Constraints can be applied to fields
  and arguments, enforcing rules such as `min`, `max`, etc. These constraints
  can be applied to both individual items and lists simultaneously.

  ## Example usage

  Add this phase to your pipeline in your router:

      pipeline =
        config
        |> Absinthe.Plug.default_pipeline(opts)
        |> AbsintheHelpers.Phases.ApplyConstraints.add_to_pipeline(opts)

  Add the constraints directive's prototype schema to your schema:

      defmodule MyApp.Schema do
        use Absinthe.Schema
        @prototype_schema AbsintheHelpers.Directives.Constraints
        # ...
      end

  Apply constraints to a field or argument:

      field :my_field, :integer, directives: [constraints: [min: 1, max: 10]] do
        resolve(&MyResolver.resolve/3)
      end

      arg :my_arg, non_null(:string), directives: [constraints: [min: 10]]

      field :my_list, list_of(:integer), directives: [constraints: [min_items: 2, max_items: 5, min: 1, max: 100]] do
        resolve(&MyResolver.resolve/3)
      end
  """

  use Absinthe.Phase

  alias Absinthe.Blueprint
  alias Absinthe.Phase
  alias Blueprint.Input

  def add_to_pipeline(pipeline, opts) do
    Absinthe.Pipeline.insert_before(
      pipeline,
      Phase.Document.Validation.Result,
      {__MODULE__, opts}
    )
  end

  @impl Absinthe.Phase
  def run(input, _opts \\ []) do
    {:ok, Blueprint.postwalk(input, &handle_node/1)}
  end

  defp handle_node(
         node = %{
           input_value: %{normalized: normalized},
           schema_node: %{__private__: private}
         }
       ) do
    if constraints?(private), do: apply_constraints(node, normalized), else: node
  end

  defp handle_node(node), do: node

  defp apply_constraints(node, list = %Input.List{items: _items}) do
    with {:ok, _list} <- validate_list(list, node.schema_node.__private__),
         {:ok, _items} <- validate_items(list.items, node.schema_node.__private__) do
      node
    else
      {:error, reason, details} -> add_custom_error(node, reason, details)
    end
  end

  defp apply_constraints(node, %{value: _value}) do
    case validate_item(node.input_value, node.schema_node.__private__) do
      {:ok, _validated_value} -> node
      {:error, reason, details} -> add_custom_error(node, reason, details)
    end
  end

  defp apply_constraints(node, _), do: node

  defp validate_list(list, private_tags) do
    apply_constraints_in_sequence(list, get_constraints(private_tags))
  end

  defp validate_items(items, private_tags) do
    Enum.reduce_while(items, {:ok, []}, fn item, {:ok, acc} ->
      case validate_item(item, private_tags) do
        {:ok, validated_item} -> {:cont, {:ok, acc ++ [validated_item]}}
        {:error, reason, details} -> {:halt, {:error, reason, details}}
      end
    end)
  end

  defp validate_item(item, private_tags) do
    apply_constraints_in_sequence(item, get_constraints(private_tags))
  end

  defp apply_constraints_in_sequence(item, constraints) do
    Enum.reduce_while(constraints, {:ok, item}, fn constraint, {:ok, acc} ->
      case call_constraint(constraint, acc) do
        {:ok, result} -> {:cont, {:ok, result}}
        {:error, reason, details} -> {:halt, {:error, reason, details}}
      end
    end)
  end

  defp call_constraint(constraint = {name, _args}, input) do
    get_constraint_module(name).call(input, constraint)
  end

  defp get_constraint_module(constraint_name) do
    String.to_existing_atom(
      "Elixir.AbsintheHelpers.Constraints.#{Macro.camelize(Atom.to_string(constraint_name))}"
    )
  end

  defp get_constraints(private), do: Keyword.get(private, :constraints, [])

  defp constraints?(private), do: private |> get_constraints() |> Enum.any?()

  defp add_custom_error(node, reason, details) do
    Phase.put_error(node, %Phase.Error{
      phase: __MODULE__,
      message: reason,
      extra: %{
        details: Map.merge(details, %{field: node.name})
      }
    })
  end
end
