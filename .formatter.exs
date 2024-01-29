[
  import_deps: [:ecto, :ecto_sql, :phoenix],
  subdirectories: ["priv/*/migrations"],
  plugins: [Styler, TailwindFormatter, Phoenix.LiveView.HTMLFormatter],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"],
  locals_without_parens: [defhandler: 2, defhandler: 3]
]
