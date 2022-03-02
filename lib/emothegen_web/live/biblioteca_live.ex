defmodule EmothegenWeb.BibliotecaLive do
  use EmothegenWeb, :live_view

  require Logger

  alias Emothegen.{Boundary, Play}
  alias Emothegen.TeiXml.TEIWatcher
  alias Emothegen.Statistics.StatisticsWatcher
  alias Emothegen.Templates.TemplatesWatcher

  @pubsub Emothegen.PubSub
  @topic "plays_gen"

  def subscribe_plays() do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: subscribe_plays()

    {
      :ok,
      socket
      |> assign(:uploaded_files, [])
      # should be taken from the DDBB!
      |> assign(:plays, Boundary.detect_TEIs_and_generate_all())
      # |> assign(:changeset, %{})
      |> allow_upload(:tei_xml,
        accept: ~w(.xml),
        auto_upload: true,
        progress: &handle_progress/3
      )
    }
  end

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  def handle_progress(:tei_xml, entry, socket) do
    if entry.done? do
      uploaded_play =
        consume_uploaded_entry(
          socket,
          entry,
          fn %{path: path} ->
            play_name = entry.client_name
            Logger.log(:info, "PROCESSING #{play_name}!")
            dest = Path.join(tei_path(), play_name)
            File.cp!(path, dest)

            {:ok, extract_play_name(play_name)}
          end
        )

      new_socket =
        socket
        # |> change(uploaded_play)
        # |> update(:plays, &[%{name: uploaded_play} | &1])
        |> update(:uploaded_files, &[uploaded_play | &1])

      {:noreply, new_socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :tei_xml, ref)}
  end

  def handle_event("remove_play", %{"play" => play_name}, socket) do
    {:noreply, socket |> remove(play_name)}
  end

  def handle_info({TEIWatcher, :init, plays}, socket) do
    Logger.info("Lib initialising...")
    {:noreply, assign(socket, :plays, plays)}
  end

  def handle_info({TEIWatcher, :add, %Play{} = new_play}, socket) do
    {:noreply, assign(socket, :plays, [new_play | socket.assigns.plays])}
  end

  def handle_info({TEIWatcher, :removed, play_name}, socket) do
    new_plays = socket.assigns.plays |> Boundary.remove_play(play_name)

    {:noreply, assign(socket, :plays, new_plays)}
  end

  def handle_info({StatisticsWatcher, :update, [stats_status: _status] = opts, play_name}, socket) do
    new_plays = socket.assigns.plays |> Boundary.update_play(play_name, opts)

    {:noreply, assign(socket, :plays, new_plays)}
  end

  def handle_info({TemplatesWatcher, :reset, plays}, socket) do
    {:noreply, assign(socket, :plays, plays)}
  end

  defp change(socket, new_play) do
    IO.inspect("new play")
    IO.inspect(new_play)
    changeset = Boundary.validate(new_play, socket.assigns.plays) |> Map.put(:action, :insert)

    assign(socket, :changeset, changeset)
  end

  defp remove(socket, play_name) do
    case Boundary.delete(play_name) do
      :ok ->
        Logger.info("#{play_name} will be removed")

      error ->
        Logger.error("File couldn't be deleted because of #{inspect(error)}")
    end

    socket
  end

  def extract_play_name(file) do
    file
    |> String.replace(".xml", "")
  end

  defp tei_path(), do: Emothegen.config([:files, :tei_dir])
end
