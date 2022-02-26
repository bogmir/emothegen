defmodule Emothegen.Boundary do
  alias Emothegen.Generators.GeneratorPhp.GenPlay
  alias Emothegen.Generators.GeneratorXml.GenXmlStatistics
  alias Emothegen.Play

  def detect_TEIs_and_generate_all do
    Path.wildcard("#{tei_path()}/*.xml")
    |> Enum.map(&generate_all/1)
    |> Enum.map(&sanitize_play/1)
  end

  def remove_all_generated(file) do
    filename = extract_filename(file)

    remove_gen_file(tei_web_path(), filename, "php")
    remove_gen_file(statistics_web_path(), filename, "php")
    remove_gen_file(statistics_xml_path(), filename, "xml")
  end

  def remove_gen_file(path, filename, ext) do
    Path.expand("#{path}/#{filename}.#{ext}")
    |> File.rm!()
  end

  def remove_play(plays, file) do
    plays
    |> Enum.filter(fn
      %Play{name: name} ->
        name != extract_filename(file)

      {name, _state} ->
        name != extract_filename(file)
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

  def get_plays() do
    Emothegen.TeiXml.TEIWatcher.get_plays()
    |> Enum.map(fn %Play{name: name, status: status} -> {name, status} end)
  end

  def generate_all(file) do
    filename = extract_filename(file)

    with :ok <- ensure_dir("web_files/plays"),
         :ok <- GenPlay.generate(file),
         :ok <- ensure_dir("xml_files/statistics"),
         :ok <- ensure_dir("web_files/statistics"),
         :ok <- GenXmlStatistics.generate(file) do
      {:ok, filename}
    else
      _err -> {:error, filename}
    end
  end

  defp sanitize_play({:ok, filename}), do: struct(Play, name: filename, status: :ok)
  defp sanitize_play({:error, filename}), do: struct(Play, name: filename, status: :error)

  def extract_filename(file) do
    file
    |> String.split(["/"])
    |> List.last()
    |> String.replace(".xml", "")
  end

  defp ensure_dir(path) do
    Path.expand("#{data_path()}/#{path}")
    |> File.mkdir_p!()
  end

  defp data_path, do: Emothegen.config([:files, :data_dir])
  defp tei_web_path, do: Emothegen.config([:files, :tei_web])
  defp tei_path, do: Emothegen.config([:files, :tei_dir])
  defp statistics_web_path, do: Emothegen.config([:files, :statistics_web])
  defp statistics_xml_path, do: Emothegen.config([:files, :statistics_xml_dir])
end
