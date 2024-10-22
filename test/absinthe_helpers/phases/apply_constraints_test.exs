defmodule AbsintheHelpers.Phases.ApplyConstraintsTest do
  use ExUnit.Case, async: true

  alias AbsintheHelpers.Phases.ApplyConstraints
  alias AbsintheHelpers.TestResolver

  describe "apply constraints phase with min/max on integers, decimals, and strings" do
    defmodule TestSchema do
      use Absinthe.Schema

      import_types(Absinthe.Type.Custom)

      @prototype_schema AbsintheHelpers.Directives.Constraints

      query do
        field :get_booking, non_null(:string) do
          resolve(&TestResolver.run/3)
        end
      end

      mutation do
        field(:create_booking, :string) do
          arg(:customer_id, non_null(:integer), directives: [constraints: [min: 1, max: 1000]])
          arg(:service, non_null(:service_input))

          resolve(&TestResolver.run/3)
        end
      end

      input_object :service_input do
        field(:cost, :decimal, directives: [constraints: [min: 10, max: 1000]])

        field(:description, :string) do
          directive(:constraints, regex: "^[a-zA-Z\s]+$", min: 5, max: 50)
        end

        field(:override_ids, non_null(list_of(non_null(:integer)))) do
          directive(:constraints, min_items: 3, min: 5, max: 50)
        end

        field(:location_ids, non_null(list_of(non_null(:integer)))) do
          directive(:constraints, min_items: 2, min: 5, max: 50)
        end

        field(:commission_ids, non_null(list_of(non_null(:integer)))) do
          directive(:constraints, max_items: 2)
        end
      end

      def run_query(query) do
        Absinthe.run(
          query,
          __MODULE__,
          pipeline_modifier: &ApplyConstraints.add_to_pipeline/2
        )
      end
    end

    test "validates mutation arguments including decimal and string constraints and returns success" do
      query = """
      mutation {
        create_booking(
          customer_id: 1,
          service: {
            cost: "150.75",
            description: "Valid description",
            override_ids: [6, 7, 8],
            location_ids: [8, 9, 10],
            commission_ids: []
          }
        )
      }
      """

      assert TestSchema.run_query(query) == {:ok, %{data: %{"create_booking" => ""}}}
    end

    test "returns errors for invalid decimal and string arguments" do
      query = """
      mutation {
        create_booking(
          customer_id: 1001,
          service: {
            cost: "5.00",
            description: "bad",
            override_ids: [6, 1, 7],
            location_ids: [1],
            commission_ids: [1, 2, 3]
          }
        )
      }
      """

      assert {:ok,
              %{
                errors: [
                  %{
                    message: :max_exceeded,
                    details: %{field: "customer_id", max: 1000}
                  },
                  %{message: :min_not_met, details: %{field: "cost", min: 10}},
                  %{message: :min_not_met, details: %{field: "description", min: 5}},
                  %{message: :min_not_met, details: %{field: "override_ids", min: 5}},
                  %{
                    message: :min_items_not_met,
                    details: %{field: "location_ids", min_items: 2}
                  },
                  %{
                    message: :max_items_exceeded,
                    details: %{field: "commission_ids", max_items: 2}
                  }
                ]
              }} = TestSchema.run_query(query)
    end

    test "returns invalid_format on strings that do not match regex pattern" do
      query = """
      mutation {
        create_booking(
          customer_id: 1,
          service: {
            cost: "150.75",
            description: "invalid-description",
            override_ids: [6, 7, 8],
            location_ids: [8, 9, 10],
            commission_ids: []
          }
        )
      }
      """

      assert {:ok,
              %{
                errors: [
                  %{
                    message: :invalid_format,
                    details: %{field: "description", regex: "^[a-zA-Z\s]+$"}
                  }
                ]
              }} = TestSchema.run_query(query)
    end
  end
end
