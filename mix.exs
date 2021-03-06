defmodule Alchemud.Mixfile do
  use Mix.Project

  def project do
    [app: :alchemud,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [
        :logger, 
        :ranch,
        :comeonin,
        :apex,
        :fsm,
        :exactor,
        :timex
      ],
      mod: {Alchemud, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      #{:exactor, "~> 2.2.0", warn_missing: false},  # Concise GenServer declarations
      {:exactor, "~>2.2.0", github: "sasa1977/exactor"},
      {:fsm, "~> 0.2.0"},                           # Finite State Machine.
      {:ranch, "~> 1.1"},                           # Pooled TCP-server connections.
      {:comeonin, "~> 2.4"},                        # BCrypt password hashing
      {:exrm, "~> 1.0"},                            # Release Manager
      {:timex, "~> 2.1"},

      {:apex, "~>0.5.0"},                           # Pretty-printing.
      {:credo, "~> 0.3", only: [:dev, :test]}

    ]
  end
end
