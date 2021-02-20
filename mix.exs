defmodule Herald.AMQP.MixProject do
  use Mix.Project

  def project do
    [
      app: :herald_amqp,
      name: "Herald.AMQP",
      version: "0.1.0",
      elixir: "~> 1.8",
      description: "Plugin to use Herald with AMQP",
      start_permanent: Mix.env() == :prod,
      package: [
        links: %{
          github: "https://github.com/radsquare/herald"
        },
        licenses: ["MIT"]
      ],
      docs: docs(),
      deps: deps()
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
      {:amqp, "~> 2.0.0"},
      {:herald, "~> 0.1"},

      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
    ]
  end

  def docs() do
    [
      extra_section: "README",
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
