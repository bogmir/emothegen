defmodule Emothegen.Boundary do
  alias Emothegen.Generators.GeneratorPhp.GenPlay
  alias Emothegen.Generators.GeneratorXml.GenXmlStatistics
  alias Emothegen.Play

  def get_plays() do
    Emothegen.TeiXml.TEIWatcher.get_plays()
    # |> Enum.map(&Map.from_struct/1)
  end

  def detect_TEIs_and_generate_all do
    Path.wildcard("#{tei_path()}/*.xml")
    |> generate_all()
  end

  def generate_all(file) when is_binary(file) do
    file
    |> do_generate_all()
    |> sanitize_play()
  end

  def generate_all(files) when is_list(files) do
    files
    |> Enum.map(&generate_all/1)
  end

  def new_plays() do
    []
  end

  def add_play(plays, file) do
    play = generate_all(file)

    [play | plays]
  end

  defp remove_all_generated(filename) do
    remove_gen_file(tei_gen_path(), filename, "xml")
    remove_gen_file(tei_web_path(), filename, "php")
    remove_gen_file(statistics_web_path(), filename, "php")
    remove_gen_file(statistics_xml_path(), filename, "xml")
  end

  defp remove_gen_file(path, filename, ext) do
    file = Path.expand("#{path}/#{filename}.#{ext}")

    if File.exists?(file),
      do: File.rm!(file),
      else: :ok
  end

  def remove_play_generated(file) do
    filename = extract_filename(file)

    case remove_all_generated(filename) do
      :ok -> {:ok, filename}
      error -> error
    end
  end

  def remove_play(plays, play_name) do
    plays
    |> Enum.filter(fn
      %Play{name: name} ->
        name != play_name

        # %{name: name} ->
        #   name != play_name
    end)
  end

  def update_play(plays, play_name, stats_status: status) do
    plays
    |> Enum.map(fn
      %Play{name: ^play_name} = play ->
        %Play{play | play_stat_html_gen: status}

      play ->
        play
    end)
  end

  def delete(play_name) do
    file = "#{tei_path()}/#{play_name}.xml"
    delete_from_path(file)
  end

  defp delete_from_path(file) do
    file
    |> Path.expand()
    |> File.rm!()
  end

  def validate(play_name, list) do
    list_plays = list |> Enum.map(&Map.get(&1, :name))
    play = %{name: play_name}
    IO.inspect("List plays")
    IO.inspect(list_plays, pretty: true)

    Play.validate(play, list_plays)
  end

  defp do_generate_all(file) do
    filename = extract_filename(file)

    with :ok <- tei_gen_path() |> ensure_dir(),
         :ok <- File.cp!(file, "#{tei_gen_path()}/#{filename}.xml"),
         :ok <- tei_web_path() |> ensure_dir(),
         play_html_gen_status <- GenPlay.generate(file),
         :ok <- statistics_xml_path() |> ensure_dir(),
         :ok <- statistics_web_path() |> ensure_dir(),
         stats_gen_status <- GenXmlStatistics.generate(file) do
      {play_html_gen_status, stats_gen_status, filename}
    else
      _err -> {:error, filename}
    end
  end

  defp sanitize_play({play_html_gen_status, stats_gen_status, name}) do
    struct(Play,
      name: name,
      play_html_gen: generated?(play_html_gen_status),
      play_stat_gen: generated?(stats_gen_status)
    )
  end

  defp sanitize_play({:error, filename}), do: struct(Play, name: filename)

  def extract_filename(file) do
    file
    |> String.split(["/"])
    |> List.last()
    |> String.replace(".xml", "")
  end

  defp ensure_dir(path) do
    path
    |> File.mkdir_p!()
  end

  defp tei_gen_path, do: Emothegen.config([:files, :tei_gen])
  defp tei_web_path, do: Emothegen.config([:files, :tei_web])
  defp tei_path, do: Emothegen.config([:files, :tei_dir])
  defp statistics_web_path, do: Emothegen.config([:files, :statistics_web])
  defp statistics_xml_path, do: Emothegen.config([:files, :statistics_xml_dir])

  defp generated?(:ok), do: true
  defp generated?(_), do: false
end
