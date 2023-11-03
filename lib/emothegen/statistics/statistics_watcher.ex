defmodule Emothegen.Statistics.StatisticsWatcher do
  use GenServer

  require Logger

  alias Emothegen.Generators.GeneratorPhp.GenStatistics

  @pubsub Emothegen.PubSub
  @topic "plays_gen"

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

    handle_generate(file, state)
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

  def handle_info({:file_event, _watcher_pid, {_path, events_not_handled}}, state) do
    Logger.warning("Events not handled #{inspect(events_not_handled)}")
    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    {:noreply, state}
  end

  defp handle_generate(file, state) do
    play_name = extract_filename(file)

    case GenStatistics.generate(file) do
      :ok ->
        broadcast_update!(play_name, stats_status: true)

      error ->
        Logger.error("Statistics xsl transformation failed with error: #{inspect(error)}!")
        broadcast_update!(play_name, stats_status: false)
    end

    {:noreply, state}
  end

  defp broadcast_update!(play_name, stats_status: status) do
    Logger.info("Broadcast stats #{play_name} update to #{status}")

    Phoenix.PubSub.broadcast!(
      @pubsub,
      @topic,
      {__MODULE__, :update, [stats_status: status], play_name}
    )
  end

  defp extract_filename(file) do
    file
    |> String.split(["/"])
    |> List.last()
    |> String.replace(".xml", "")
  end
end
