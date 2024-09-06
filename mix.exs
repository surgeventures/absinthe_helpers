defmodule AbsintheHelpers.MixProject do
  use Mix.Project

  def project do
    [
      app: :absinthe_helpers,
      version: "0.1.1",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:junit_formatter, "~> 3.3", only: [:test]},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      licenses: [],
      links: %{"GitHub" => "https://github.com/surgeventures/absinthe_helpers"},
      organization: "fresha"
    ]
  end

  defp description do
    """
    Adds support for schema constraints, type coercions, and other custom transformations.
    """
  end
end
