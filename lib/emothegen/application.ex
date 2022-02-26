defmodule Emothegen.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    tei_dir = Emothegen.config([:files, :tei_dir])
    statistics_dir = Emothegen.config([:files, :statistics_xml_dir])
    templates_dir = Emothegen.config([:files, :templates_dir])

    children = [
      # Start the Ecto repository
      Emothegen.Repo,
      # Start the Telemetry supervisor
      EmothegenWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Emothegen.PubSub},
      # Start the Endpoint (http/https)
      EmothegenWeb.Endpoint,
      # Start a worker by calling: Emothegen.Worker.start_link(arg)
      # {Emothegen.Worker, arg}
      {Emothegen.TeiXml.TEIWatcher, dirs: [tei_dir]},
      {Emothegen.Statistics.StatisticsWatcher, dirs: [statistics_dir]},
      {Emothegen.Templates.TemplatesWatcher, dirs: [templates_dir]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Emothegen.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EmothegenWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
