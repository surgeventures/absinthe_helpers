defmodule AbsintheHelpers.Phases.ApplyTransforms do
  @moduledoc """
  The module identifies input nodes with transformation metadata and applies
  them to the values. These transformations can be applied to both single-value
  nodes and lists of items.

  New transformations can be added in the `lib/transforms/` directory, like
  `AbsintheHelpers.Transforms.ToIntegerTransform`, or within your own project,
  as long as they follow the convention. For example, you could define a new
  `:increment` transformation tag and create a corresponding
  `AbsintheHelpers.Transforms.IncrementTransform` to increment numeric input
  values.

  ## Example Usage

  To add this phase to your pipeline, add the following to your router:

      forward "/graphql",
          to: Absinthe.Plug,
          init_opts: [
            schema: MyProject.Schema,
            pipeline: {__MODULE__, :absinthe_pipeline},
          ]

      def absinthe_pipeline(config, opts) do
        config
        |> Absinthe.Plug.default_pipeline(opts)
        |> AbsintheHelpers.Phases.ApplyTransforms.add_to_pipeline(opts)
      end

  To define a custom transformation on a schema field:

      field :employee_id, :id do
        meta transforms: [:trim, :to_integer, :increment]
      end

  or on a list:

      field :employee_ids, non_null(list_of(non_null(:id))) do
        meta transforms: [:trim, :to_integer, :increment]
      end

  To define a custom transformation on a schema arg:

      field(:create_booking, :string) do
        arg(:employee_id, non_null(:id),
          __private__: [meta: [transforms: [:trim, :to_integer, :increment]]]
        )

        resolve(&TestResolver.run/3)
      end

  In this case, both the `TrimTransforms`, `ToIntegerTransform`, and `IncrementTransform`
  will be applied to the `employee_id` field.
  """

  use Absinthe.Phase

  alias Absinthe.Blueprint
  alias Absinthe.Blueprint.Input

  def add_to_pipeline(pipeline, opts) do
    Absinthe.Pipeline.insert_before(
      pipeline,
      Absinthe.Phase.Document.Validation.Result,
      {__MODULE__, opts}
    )
  end

  def run(input, _opts \\ []) do
    {:ok, Blueprint.postwalk(input, &handle_node/1)}
  end

  defp handle_node(
         %{
           input_value: %{normalized: normalized},
           schema_node: %{__private__: private}
         } = node
       ) do
    if transform?(private), do: apply_transforms(node, normalized), else: node
  end

  defp handle_node(node), do: node

  defp apply_transforms(node, %Input.List{items: items}) do
    case transform_items(items, node.schema_node.__private__) do
      {:ok, new_items} ->
        %{node | input_value: %{node.input_value | normalized: %Input.List{items: new_items}}}

      {:error, reason} ->
        add_custom_error(node, reason)
    end
  end

  defp apply_transforms(node, %{value: _value}) do
    case transform_item(node.input_value, node.schema_node.__private__) do
      {:ok, transformed_value} ->
        %{node | input_value: %{node.input_value | data: transformed_value.data}}

      {:error, reason} ->
        add_custom_error(node, reason)
    end
  end

  defp apply_transforms(node, _), do: node

  defp transform_items(items, private_tags) do
    Enum.reduce_while(items, {:ok, []}, fn item, {:ok, acc} ->
      case transform_item(item, private_tags) do
        {:ok, transformed_item} -> {:cont, {:ok, acc ++ [transformed_item]}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp transform_item(item, private_tags) do
    transform_in_sequence(
      item,
      get_transforms(private_tags)
    )
  end

  defp transform_in_sequence(item, [first_transform | other_transforms]) do
    Enum.reduce(
      other_transforms,
      call_transform(first_transform, item),
      &transform_in_sequence_each/2
    )
  end

  defp transform_in_sequence(item, []), do: {:ok, item}

  defp transform_in_sequence_each(_next_transform, {:error, reason}), do: {:error, reason}

  defp transform_in_sequence_each(next_transform, {:ok, prev_output}) do
    call_transform(next_transform, prev_output)
  end

  defp call_transform(transforms, input) when is_list(transforms),
    do: transform_in_sequence(input, transforms)

  defp call_transform(transform, input) when is_atom(transform),
    do: call_transform({transform}, input)

  defp call_transform(transform_tuple, input) when is_tuple(transform_tuple) do
    [transform_name | transform_args] = Tuple.to_list(transform_tuple)
    transform_args = if transform_args == [], do: [nil], else: transform_args

    transform_camelized =
      transform_name
      |> Atom.to_string()
      |> Macro.camelize()

    transform_module =
      String.to_existing_atom("Elixir.AbsintheHelpers.Transforms.#{transform_camelized}Transform")

    apply(transform_module, :call, [input | transform_args])
  end

  defp get_transforms(private) do
    private
    |> Keyword.get(:meta, [])
    |> Keyword.get(:transforms, [])
  end

  defp transform?(private) do
    private
    |> get_transforms()
    |> Enum.any?()
  end

  defp add_custom_error(node, reason) do
    Absinthe.Phase.put_error(node, %Absinthe.Phase.Error{
      phase: __MODULE__,
      message: reason
    })
  end
end