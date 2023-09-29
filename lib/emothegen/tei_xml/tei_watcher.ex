defmodule Emothegen.TeiXml.TEIWatcher do
  use GenServer

  require Logger

  alias Emothegen.{Play, Boundary}

  @pubsub Emothegen.PubSub
  @topic "plays_gen"

  def start_link([dirs: dirs] = args) do
    Logger.info("Starting to listen for TEI files at: #{inspect(dirs)}")

    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def get_plays() do
    GenServer.call(__MODULE__, :get_plays)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(args)
    FileSystem.subscribe(watcher_pid)

    state = %{watcher_pid: watcher_pid, plays: []}

    {:ok, state, {:continue, :init_tei_watcher}}
  end

  def handle_continue(:init_tei_watcher, state) do
    {
      :noreply,
      %{state | plays: Emothegen.Boundary.detect_TEIs_and_generate_all()}
    }
  end

  def handle_info(
        {:file_event, watcher_pid, {file, events}},
        %{watcher_pid: watcher_pid} = state
      )
      when events in [[:modified, :closed], [:moved_to]] do
    Logger.info("Add event triggered: #{inspect(events)}")
    Logger.info("Processing file: #{inspect(file)}")

    handle_generate_files(file, state)
  end

  def handle_info(
        {:file_event, watcher_pid, {file, events}},
        %{watcher_pid: watcher_pid} = state
      )
      when events in [[:moved_from], [:deleted]] do
    Logger.info("Remove event triggered: #{inspect(events)}")

    handle_remove_generated_files(file, state)
  end

  def handle_info({:file_event, _watcher_pid, {_path, events_not_handled}}, state) do
    Logger.warning("events: #{inspect(events_not_handled)}")
    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    {:noreply, state}
  end

  defp handle_remove_generated_files(file, state) do
    {:ok, play_name} = Boundary.remove_play_generated(file)

    broadcast_removed!(play_name)

    {:noreply, state}
  end

  defp handle_generate_files(file, state) do
    Boundary.generate_all(file)
    |> broadcast_add!()

    {:noreply, state}
  end

  defp broadcast_add!(%Play{} = play) do
    Logger.info("Broadcast #{play.name} added")
    Phoenix.PubSub.broadcast!(@pubsub, @topic, {__MODULE__, :add, play})
  end

  defp broadcast_removed!(play_name) do
    Logger.info("Broadcast #{play_name} removed")
    Phoenix.PubSub.broadcast!(@pubsub, @topic, {__MODULE__, :removed, play_name})
  end
end
