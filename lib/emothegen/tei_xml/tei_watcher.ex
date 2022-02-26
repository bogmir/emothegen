defmodule Emothegen.TeiXml.TEIWatcher do
  use GenServer

  require Logger

  alias Emothegen.{Boundary, Plays}

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

    state = %{watcher_pid: watcher_pid, plays: Plays.new()}

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
    Logger.info("Event triggered: #{inspect(events)}")
    Logger.info("Processing file: #{inspect(file)}")

    handle_generate_files(file, state)
  end

  def handle_info(
        {:file_event, watcher_pid, {file, events}},
        %{watcher_pid: watcher_pid} = state
      )
      when events in [[:moved_from], [:deleted]] do
    Logger.info("Events: #{inspect(events)}")
    # TODO: remove generated with error handling?
    Boundary.remove_all_generated(file)

    {:noreply, %{state | plays: state.plays |> Boundary.remove_play(file)}}
  end

  def handle_info({:file_event, _watcher_pid, {_path, events_not_handled}}, state) do
    IO.inspect("events: #{inspect(events_not_handled)}")
    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    {:noreply, state}
  end

  def handle_call(:get_plays, _from, state) do
    {:reply, state.plays, state}
  end

  defp handle_generate_files(file, state) do
    {status, filename} = Emothegen.Boundary.generate_all(file)

    {
      :noreply,
      %{state | plays: state.plays |> Plays.add(filename, status)}
    }
  end
end
