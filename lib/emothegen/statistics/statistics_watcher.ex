defmodule Emothegen.Statistics.StatisticsWatcher do
  use GenServer

  require Logger

  alias Emothegen.Generators.GeneratorPhp.GenStatistics

  def start_link([dirs: dirs] = args) do
    Logger.info("Starting to listen for statistics files at: #{inspect(dirs)}")

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

    GenStatistics.generate(file)

    {:noreply, state}
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
end
