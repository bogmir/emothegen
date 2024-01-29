import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :emothegen, Emothegen.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "emothegen_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :emothegen, EmothegenWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "TKmNZxSTeflOemWVZQ/Mnz+GiWVN8wZA77NLY7WZdmbJMQEQl4D1SzWLP2SIIXp7",
  server: false

# In test we don't send emails.
config :emothegen, Emothegen.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :emothegen, :files,
  tei_dir: Path.expand("../test/support/tei_files", __DIR__),
  tei_gen: Path.expand("../test/support/generated/tei_files", __DIR__),
  tei_web: Path.expand("../test/support/generated/web_files/plays", __DIR__),
  tei_template: Path.expand("../priv/xsl_templates/TEI2HTML-i18n.xsl", __DIR__),
  statistics_xml_dir: Path.expand("../test/support/generated/xml_files/statistics", __DIR__),
  statistics_web: Path.expand("../test/support/generated/web_files/statistics", __DIR__),
  statistics_template:
    Path.expand("../priv/xsl_templates/transformarEstadisticas-i18n.xsl", __DIR__),
  templates_dir: Path.expand("../priv/xsl_templates", __DIR__)
