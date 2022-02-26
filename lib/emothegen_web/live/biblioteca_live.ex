defmodule EmothegenWeb.BibliotecaLive do
  use EmothegenWeb, :live_view

  require Logger

  alias EmothegenWeb.Heading
  alias Emothegen.Boundary

  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:plays, Boundary.get_plays())
      |> assign(:uploaded_files, [])
      |> allow_upload(:tei_xml, accept: ~w(.xml), auto_upload: true, progress: &handle_progress/3)
    }
  end

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign(:plays, Boundary.get_plays())}
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
        |> update(:plays, &[{uploaded_play, :pending} | &1])
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

  defp remove(socket, play_name) do
    case Boundary.delete(play_name) do
      :ok ->
        assign(socket, :plays, Boundary.remove_play(socket.assigns.plays, play_name))

      error ->
        Logger.error("File couldn't be deleted because of #{inspect(error)}")
        socket
    end
  end

  def extract_play_name(file) do
    file
    |> String.replace(".xml", "")
  end

  defp tei_path(), do: Emothegen.config([:files, :tei_dir])
end
