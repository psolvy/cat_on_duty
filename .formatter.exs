[
  import_deps: [:ecto, :phoenix],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs:
    Enum.flat_map(
      ["*.{heex,ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{heex,ex,exs}"],
      &Path.wildcard(&1, match_dot: true)
    ) --
      ["lib/cat_on_duty_web/templates/layout/live.html.heex"],
  subdirectories: ["priv/*/migrations"],
  line_length: 100,
  heex_line_length: 120
]
