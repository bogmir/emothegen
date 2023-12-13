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
      |> assign(:plays, Boundary.detect_TEIs_and_generate_all())
      |> assign(changeset: Emothegen.Play.changeset(%{}), error_messages: [])
      |> allow_upload(:tei_xml,
        accept: ~w(.xml),
        auto_upload: true,
        progress: &handle_progress/3
      )
    }
  end

  def handle_progress(:tei_xml, entry, socket) do
    if entry.done? do
      uploaded_play =
        consume_uploaded_entry(
          socket,
          entry,
          fn %{path: path} ->
            file_name = entry.client_name
            play_name = extract_play_name(file_name)

            Logger.log(:info, "PROCESSING #{play_name} in Liveview!")

            dest = Path.join(tei_path(), file_name)

            if entry_file_already_exists?(socket, play_name) do
              {:ok, {:error, :duplicate}}
            else
              File.cp!(path, dest)
              {:ok, play_name}
            end
          end
        )

      {:noreply, socket |> put_flash(uploaded_play)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("remove_play", %{"play" => play_name}, socket) do
    {:noreply, socket |> clear_flash() |> remove(play_name)}
  end

  # ####################### PUBSUB HANDLERS ######################################3
  def handle_info({TEIWatcher, :init, plays}, socket) do
    Logger.info("Lib initialising...")
    {:noreply, assign(socket, :plays, plays)}
  end

  def handle_info({TEIWatcher, :add, %Play{} = new_play}, socket) do
    {:noreply,
     socket
     |> assign(:plays, [new_play | socket.assigns.plays])}
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

  # ####################### HELPERS ######################################3

  defp put_flash(socket, {:error, :duplicate}),
    do:
      socket
      |> clear_flash()
      |> put_flash(
        :error,
        "File was not uploaded because it already exists. Please remove the previous first!"
      )

  defp put_flash(socket, _uploaded_play),
    do:
      socket
      |> clear_flash()
      |> put_flash(:info, "File successfuly uploaded")

  defp entry_file_already_exists?(socket, play_name) do
    socket.assigns.plays
    |> Enum.any?(fn %Play{name: name} -> name == play_name end)
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

  defp extract_play_name(file) do
    file
    |> String.replace(".xml", "")
  end

  defp tei_path(), do: Emothegen.config([:files, :tei_dir])
end
