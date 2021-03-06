defmodule Iexfly.Mixfile do
  use Mix.Project

  def project do
    [app: :iexfly,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     gettext: [{:compiler_po_wildcard, "gettext/*/LC_MESSAGES/*.po"}],
     compilers: [:gettext] ++ Mix.compilers]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :ecto, :cowboy, :plug, :gettext]]
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
    [{:cowboy, "~> 1.0.0"},
    {:plug, "~> 1.0"},
    {:ecto, "~> 1.0"},
    {:socket, "~> 0.3"},
    {:jazz, "~> 0.2.1"},
    #{:erlydtl, github: "erlydtl/erlydtl"}]
    #not forget change version to 'vsn,"0.12.1"' in deps/erlydtl/ebin after "mix deps.get"
    {:erlydtl, "~> 0.12.1", override: true},
    {:gettext, "~> 0.13.1"}]
  end
end
