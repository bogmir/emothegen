import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# Start the phoenix server if environment is set and running in a release
if System.get_env("PHX_SERVER") && System.get_env("RELEASE_NAME") do
  config :emothegen, EmothegenWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :emothegen, Emothegen.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :emothegen, :files,
    tei_dir: Path.expand("/app/lib/emothegen-0.1.0/priv/tei_files", __DIR__),
    tei_gen: Path.expand("/app/lib/emothegen-0.1.0/priv/static/generated/tei_files", __DIR__),
    tei_web:
      Path.expand(
        "/app/lib/emothegen-0.1.0/priv/static/generated/web_files/plays",
        __DIR__
      ),
    tei_template:
      Path.expand("/app/lib/emothegen-0.1.0/priv/xsl_templates/TEI2HTML-i18n.xsl", __DIR__),
    statistics_xml_dir:
      Path.expand(
        "/app/lib/emothegen-0.1.0/priv/static/generated/xml_files/statistics",
        __DIR__
      ),
    statistics_web:
      Path.expand(
        "/app/lib/emothegen-0.1.0/priv/static/generated/web_files/statistics",
        __DIR__
      ),
    statistics_template:
      Path.expand(
        "/app/lib/emothegen-0.1.0/priv/xsl_templates/transformarEstadisticas-i18n.xsl",
        __DIR__
      ),
    templates_dir: Path.expand("/app/lib/emothegen-0.1.0/priv/xsl_templates", __DIR__)

  config :emothegen, EmothegenWeb.Endpoint,
    url: [host: host, port: 443],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  #     config :emothegen, EmothegenWeb.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :emothegen, Emothegen.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
