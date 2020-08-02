defmodule Crawlex.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :crawlex,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Crawlex",
      source_url: "https://github.com/abiwinanda/crawlex",
      docs: docs()
    ]
  end

  defp description() do
    "Crawler in elixir."
  end

  defp package() do
    [
      # These are the default files included in the package
      maintainers: ["Nyoman Abiwinanda"],
      files: [
        "lib/mix/tasks/crawlex.ex",
        "lib/crawlex.ex",
        "lib/formatter.ex",
        "mix.exs",
        "LICENSE.md",
        "README.md",
        ".formatter.exs"
      ],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/abiwinanda/crawlex"}
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
      {:ex_doc, "~> 0.22.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: Crawlex,
      source_ref: "v#{@version}",
      source_url: "https://github.com/abiwinanda/crawlex"
    ]
  end
end
