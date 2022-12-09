defmodule Emothegen do
  @moduledoc """
  The main interface for shared functionality.
  """
  require Logger

  @doc """
  Looks up `Application` config or raises if keyspace is not configured.
  ## Examples
      config :emothegen, :files, [
        uploads_dir: Path.expand("../priv/uploads", __DIR__),
        host: [scheme: "http", host: "localhost", port: 4000],
      ]
      iex> Emothegen.config([:files, :uploads_dir])
      iex> Emothegen.config([:files, :host, :port])
  """
  def config([main_key | rest] = keyspace) when is_list(keyspace) do
    main = Application.fetch_env!(:emothegen, main_key)

    Enum.reduce(rest, main, fn next_key, current ->
      case Keyword.fetch(current, next_key) do
        {:ok, val} -> val
        :error -> raise ArgumentError, "no config found under #{inspect(keyspace)}"
      end
    end)
  end
end
