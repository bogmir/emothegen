defmodule Emothegen.Generators.GeneratorXml.GenXmlStatistics do
  use Emothegen.Generators.GeneratorXml

  import XmlBuilder

  alias Emothegen.Statistics
  alias Emothegen.TeiXml.TeiParser

  @impl true
  @spec generate_content(binary) :: {:error, <<_::64, _::_*8>>} | {:ok, binary, binary}
  def generate_content(xml_str) do
    try do
      Logger.info("Attempting to parse xml for Statistics")

      content =
        TeiParser.parse(xml_str)
        |> statistics_to_xml()

      Logger.info(destination_path())
      {:ok, destination_path(), content}
    rescue
      e in ArgumentError ->
        Logger.error("Error to parsing XML: #{inspect(e)}")
        raise "error"
    catch
      :exit, _e ->
        raise "error"
    end
  end

  def statistics_to_xml(%Statistics{} = statistics) do
    tipos_secciones = get_tipo_secciones(statistics.estructura.tipo_secciones)
    escenas = get_escenas(statistics)

    estructura = [
      element(:totalEstructura, statistics.estructura.num_secciones),
      element(:tipoSecciones, tipos_secciones),
      element(:escenas, escenas)
    ]

    total_lineas = [
      element(:totalLineas, statistics.lineas.total_lineas)
    ]

    lineas_acto =
      get_lineas_acto(
        statistics.lineas.tipo_lineas,
        statistics.lineas.versos_acto,
        statistics.lineas.parrafos_acto
      )

    versos_truncados = [
      element(:versosTruncados, statistics.lineas.num_versos_partidos)
    ]

    total_fragmentos =
      get_total_fragmentos(statistics.lineas.tipo_lineas, statistics.lineas.total_fragmentos)

    fragmentos =
      get_fragmentos_acto(
        statistics.lineas.tipo_lineas,
        statistics.lineas.versos_acto,
        statistics.lineas.parrafos_acto
      )

    lineas = total_lineas ++ lineas_acto ++ versos_truncados ++ total_fragmentos ++ fragmentos

    acotaciones = [
      element(:totalAcotaciones, statistics.acotaciones)
    ]

    apartes = [
      element(:totalApartes, statistics.apartes.num_apartes),
      element(:versosAparte, statistics.apartes.versos_aparte),
      element(:etiquetasAparte, statistics.apartes.etiquetas_aparte)
    ]

    intervenciones_unica = get_intervenciones_unica(statistics.intervenciones)
    intervenciones_multiple = get_intervenciones_multiple(statistics.intervenciones)

    estrofas = get_estrofas(statistics.estrofas)

    estudio_metrica = get_lineas_estudio_metrica(statistics.estudio_metrica)

    estadisticas =
      [
        element(:tituloObra, statistics.titulo_obra),
        element(:tituloArchivo, statistics.titulo_archivo),
        element(:idioma, statistics.idioma),
        element(:estructura, %{tipo: statistics.estructura.tipo_estructura}, estructura),
        element(:lineas, %{tipo: statistics.lineas.tipo_lineas}, lineas),
        element(:acotaciones, acotaciones),
        element(:apartes, apartes),
        element(:intervenciones, %{tipo: "unica"}, intervenciones_unica)
      ]
      |> maybe_add(element(:intervenciones, %{tipo: "multiple"}, intervenciones_multiple))
      |> maybe_add([
        element(:estrofas, estrofas),
        element(:estudioMetrica, estudio_metrica)
      ])

    [estadisticasObra: estadisticas]
    |> XmlBuilder.document()
    |> XmlBuilder.generate()
  end

  def get_intervenciones_unica(intervenciones) do
    intervenciones
    |> Enum.filter(fn intervencion -> intervencion.tipo == "unica" end)
    |> Enum.map(fn intervencion -> element(:intervencion, intervencion_unica(intervencion)) end)
  end

  def get_intervenciones_multiple(intervenciones) do
    intervenciones
    |> Enum.filter(fn intervencion -> intervencion.tipo == "multiple" end)
    |> Enum.map(fn intervencion -> element(:intervencion, intervencion_multiple(intervencion)) end)
  end

  def intervencion_unica(intervencion) do
    [
      element(:personaje, intervencion.personaje),
      element(:numVersos, intervencion.versos),
      element(:numVersosPartidos, intervencion.versos_partidos),
      element(:numIntervenciones, intervencion.intervenciones),
      element(:numVersosConjunto, intervencion.versos_conjunto),
      element(:numVersosPartidosConjunto, intervencion.versos_partidos_conjunto),
      element(:numIntervencionesConjunto, intervencion.intervenciones_conjunto)
    ]
  end

  def intervencion_multiple(intervencion) do
    [
      element(:personaje, intervencion.personaje),
      element(:numVersos, intervencion.versos),
      element(:numVersosPartidos, intervencion.versos_partidos),
      element(:numIntervenciones, intervencion.intervenciones)
    ]
  end

  defp get_estrofas(estrofas) do
    estrofas
    |> Enum.map(&element(:estrofa, get_estrofa(&1)))
  end

  defp get_estrofa(estrofa) do
    [
      element(:nombreEstrofa, estrofa.nombre_estrofa),
      element(:numVersos, estrofa.num_versos),
      element(:numEstrofas, estrofa.num_estrofas)
    ]
  end

  defp get_lineas_estudio_metrica(estudio_metrica) do
    estudio_metrica
    |> Enum.map(&element(:lineaEstudioMetrica, get_linea_estudio_metrica(&1)))
  end

  defp get_linea_estudio_metrica(%{
         nombre_estrofa: nombre_estrofa,
         num_verso_inicial: nvi,
         num_verso_final: nvf
       }) do
    [element(:tipoEstrofa, nombre_estrofa), element(:rango, "#{nvi} - #{nvf}")]
  end

  defp get_escenas(statistics) do
    [
      element(:totalEscenas, statistics.estructura.escenas.total_escenas)
      | get_escenas_acto(statistics.estructura.escenas.escenas_acto)
    ]
  end

  defp get_escenas_acto(escenas_acto), do: generate_numbered_list(escenas_acto, :escenasActo)

  defp get_tipo_secciones(tipo_secciones),
    do: generate_numbered_list(tipo_secciones, :tipoSeccion)

  defp get_lineas_acto("verso", versos_acto, _parrafos_acto),
    do: generate_numbered_list(versos_acto, :lineasActo)

  defp get_lineas_acto("prosa", _versos_acto, parrafos_acto),
    do: generate_numbered_list(parrafos_acto, :lineasActo)

  defp get_lineas_acto(_default_versos, _versos_acto, _parrafos_acto), do: []

  defp get_fragmentos_acto("verso", _versos_acto, parrafos_acto),
    do: generate_numbered_list(parrafos_acto, :fragmentosProsaActo)

  defp get_fragmentos_acto("prosa", versos_acto, _parrafos_acto),
    do: generate_numbered_list(versos_acto, :fragmentosVersoActo)

  defp get_fragmentos_acto(_default_versos, _versos_acto, _parrafos_acto), do: []

  defp get_total_fragmentos("verso", total_fragmentos),
    do: [
      element(:fragmentosProsa, total_fragmentos)
    ]

  defp get_total_fragmentos("prosa", total_fragmentos),
    do: [
      element(:fragmentosVerso, total_fragmentos)
    ]

  defp get_total_fragmentos(_different_tag, _total_fragmentos), do: []

  defp generate_numbered_list(list, tag_name) do
    list
    |> Enum.with_index(1)
    |> Enum.map(fn {val, idx} -> element(tag_name, %{n: idx}, val) end)
  end

  defp maybe_add(list, element) when is_map(element) or is_tuple(element), do: list ++ [element]
  defp maybe_add(list, another_list) when is_list(another_list), do: list ++ another_list
  defp maybe_add(list, _whatever), do: list

  defp destination_path, do: Emothegen.config([:files, :statistics_xml_dir])
end
