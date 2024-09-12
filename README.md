# Absinthe Helpers

This package provides two key features:

1. **constraints**: enforce validation rules (like `min`, `max`, etc.) on fields and arguments in your schema.
2. **transforms**: apply custom transformations (like `Trim`, `ToInteger`, etc.) to input fields and arguments.

## Installation

Add `absinthe_helpers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:absinthe_helpers, "~> 0.1.0"}
  ]
end
```

Then, run:

```bash
mix deps.get
```

### Setup: adding constraints and transforms to your Absinthe pipeline

To set up both **constraints** and **transforms**, follow these steps:

1. Add constraints and transforms to your Absinthe pipeline:

```elixir
forward "/graphql",
    to: Absinthe.Plug,
    init_opts: [
      schema: MyProject.Schema,
      pipeline: {__MODULE__, :absinthe_pipeline},
    ]

def absinthe_pipeline(config, opts) do
  config
  |> Absinthe.Plug.default_pipeline(opts)
  |> AbsintheHelpers.Phases.ApplyConstraints.add_to_pipeline(opts)
  |> AbsintheHelpers.Phases.ApplyTransforms.add_to_pipeline(opts)
end
```

2. Add constraints to your schema:

```elixir
defmodule MyApp.Schema do
  use Absinthe.Schema
  @prototype_schema AbsintheHelpers.Directives.Constraints
  # ...
end
```

---

## Constraints

The `constraints` directive allows you to enforce validation rules on fields and arguments in your GraphQL schema. Constraints are applied at the schema level and are visible in the GraphQL schema, making them accessible to the frontend.

### Example: graphql schema with constraints

```graphql
"Overrides for location-specific service pricing."
input LocationOverrideInput {
  duration: Int @constraints(min: 300, max: 43200)
  price: Decimal @constraints(min: 0, max: 100000000)
  priceType: ServicePriceType
  locationId: ID!
}
```

### How to use constraints

1. Apply constraints to a field or argument:

```elixir
field :my_list, list_of(:integer) do
  directive(:constraints, [min_items: 2, max_items: 5, min: 1, max: 100])

  resolve(&MyResolver.resolve/3)
end

field :my_field, :integer do
  arg :my_arg, non_null(:string), directives: [constraints: [min: 10]]

  resolve(&MyResolver.resolve/3)
end
```

---

## Transforms

Transforms allow you to modify or coerce input values at runtime. You can apply these transformations to individual fields, lists, or arguments in your Absinthe schema.

### Example: applying transforms in your schema

1. Apply transforms directly to a field:

```elixir
alias AbsintheHelpers.Transforms.ToInteger
alias AbsintheHelpers.Transforms.Trim
alias AbsintheHelpers.Transforms.Increment

field :employee_id, :id do
  meta transforms: [Trim, ToInteger, {Increment, 3}]
end
```

2. Apply transforms to a list of values:

```elixir
field :employee_ids, non_null(list_of(non_null(:id))) do
  meta transforms: [Trim, ToInteger, {Increment, 3}]
end
```

3. Apply transforms to an argument:

```elixir
field(:create_booking, :string) do
  arg(:employee_id, non_null(:id),
    __private__: [meta: [transforms: [Trim, ToInteger, {Increment, 3}]]]
  )

  resolve(&TestResolver.run/3)
end
```
