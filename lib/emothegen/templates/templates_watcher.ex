defmodule Emothegen.Templates.TemplatesWatcher do
  use GenServer

  require Logger

  alias Emothegen.Boundary

  @pubsub Emothegen.PubSub
  @topic "plays_gen"

  def start_link([dirs: dirs] = args) do
    Logger.info("Starting to listen for templates changes at: #{inspect(dirs)}")

    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(args)
    FileSystem.subscribe(watcher_pid)

    {:ok, %{watcher_pid: watcher_pid}}
  end

  def handle_info(
        {:file_event, watcher_pid, {file, events}},
        %{watcher_pid: watcher_pid} = state
      )
      when events in [[:modified, :closed], [:moved_to]] do
    Logger.info("Event triggered: #{inspect(events)}")
    Logger.info("Processing file: #{inspect(file)}")

    handle_generate(state)
  end

  def handle_info(
        {:file_event, watcher_pid, {_path, events}},
        %{watcher_pid: watcher_pid} = state
      )
      when events in [:moved_from] do
    Logger.info("Events: #{inspect(events)}")
    Logger.info("Handling removal not implemented")

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, {_path, _events_not_handled}}, state) do
    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    {:noreply, state}
  end

  defp handle_generate(state) do
    plays = Boundary.detect_TEIs_and_generate_all()
    broadcast_reset!(plays)
    {:noreply, state}
  end

  defp broadcast_reset!(plays) do
    Logger.info("Broadcast reset!")

    Phoenix.PubSub.broadcast!(
      @pubsub,
      @topic,
      {__MODULE__, :reset, plays}
    )
  end
end
