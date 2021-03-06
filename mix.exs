defmodule Conform.Mixfile do
  use Mix.Project

  @compile_peg_task "tasks/compile.peg.exs"
  @do_peg_compile?  File.exists?(@compile_peg_task)
  if @do_peg_compile? do
    Code.eval_file @compile_peg_task
  end

  def project do
    [app: :conform,
     version: "1.0.0-rc8",
     elixir: "~> 1.0",
     escript: [main_module: Conform],
     compilers: compilers(@do_peg_compile?),
     description: description,
     package: package,
     deps: deps(@do_peg_compile?)]
  end

  def application do
    case @do_peg_compile? do
      true ->
        [applications: [:neotoma]]
      false ->
        [applications: []]
    end
  end

  defp compilers(true), do: [:peg, :erlang, :elixir, :app]
  defp compilers(_),    do: nil

  defp deps(true) do
    [{:neotoma, "~> 1.7.3"},
     {:ex_doc, "~> 0.10", only: :dev},
     {:earmark, "> 0.0.0", only: :dev}]
  end
  defp deps(_), do: []

  defp description, do: "Easy release configuration for Elixir apps."
  defp package do
    [ files: ["lib", "src", "priv", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Paul Schoenfelder"],
      licenses: ["MIT"],
      links: %{ "GitHub": "https://github.com/bitwalker/conform" } ]
  end
end
