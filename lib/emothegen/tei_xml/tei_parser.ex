defmodule Emothegen.TeiXml.TeiParser do
  @moduledoc """
  A XML-TEI Parser for theatre plays edited for the Emothe project
  """

  alias Emothegen.Statistics

  import SweetXml, only: [xpath: 2, xpath: 3, sigil_x: 2, transform_by: 2]

  @doc """
  Parses TEI file to get statistics related data

  Returns Statistics Struct
  """
  @spec parse(String.t()) :: Statistics.t()
  def parse(xml_str) do
    doc = SweetXml.parse(xml_str)

    titulo_obra = xpath(doc, ~x"//titleStmt/title[1]/text()"s)
    titulo_archivo = xpath(doc, ~x"//titleStmt/title[@key='archivo']/text()"s)

    idioma = xpath(doc, ~x"//language/@ident"s)

    num_secciones = xpath(doc, ~x"count(//div1)"i)

    estructura = get_estructura(doc, num_secciones)

    lineas = get_lineas(doc, num_secciones)

    apartes = get_apartes(doc)

    num_acotaciones = xpath(doc, ~x"count(//stage)"i)

    cast = get_cast(doc)

    intervenciones = get_personajes_intervenciones(doc, cast)

    estudio_metrica = get_estudio_metrica(doc)
    estrofas = get_estrofas(doc)

    Statistics.__struct__(
      titulo_obra: titulo_obra,
      titulo_archivo: titulo_archivo,
      idioma: idioma,
      estructura: estructura,
      lineas: lineas,
      acotaciones: num_acotaciones,
      apartes: apartes,
      intervenciones: intervenciones,
      estrofas: estrofas,
      estudio_metrica: estudio_metrica
    )
  end

  defp get_estructura(doc, num_secciones) do
    headers = xpath(doc, ~x"//div1/head/text()"ls)

    tipo_secciones = get_tipo_secciones(doc)

    num_actos = get_num_actos(headers)

    particion = get_particion(headers, num_actos)

    escenas = get_escenas(doc, num_secciones)

    tipo_estructura =
      case particion do
        val when val in ["acto", "atto", "act"] -> "actos"
        val when val in ["jornada", "journée"] -> "jornadas"
        _ -> List.first(tipo_secciones)
      end

    %{
      tipo_estructura: tipo_estructura,
      num_secciones: num_secciones,
      tipo_secciones: tipo_secciones,
      escenas: escenas
    }
  end

  defp get_escenas(doc, num_secciones) do
    total_escenas = xpath(doc, ~x"count(//div2)"i)

    escenas_acto =
      1..num_secciones
      |> Enum.map(&xpath(doc, ~x"count(//div1[#{&1}]//div2)"i))

    %{total_escenas: total_escenas, escenas_acto: escenas_acto}
  end

  defp get_tipo_secciones(doc) do
    doc
    |> xpath(~x"//div1"l,
      header: ~x"head/text()"s |> transform_by(&process_head_text/1),
      type: ~x"@type"s,
      n: ~x"@n"s
    )
    |> Enum.map(fn
      %{header: h, type: "act", n: n} when is_nil(h) or h == "" ->
        "Act #{String.upcase(n)}"

      %{header: h} when is_nil(h) or h == "" ->
        ""

      %{header: header} ->
        [tipo_seccion, number | _] = header |> String.split(" ")

        String.capitalize(tipo_seccion) <> " " <> String.upcase(number)
    end)
  end

  defp process_head_text(head) do
    head
    |> String.split(" ")
    |> Enum.with_index()
    |> Enum.map_join(" ", fn
      {head_type, 0} -> String.capitalize(head_type)
      {head_number, _idx} -> head_number
    end)
  end

  defp get_particion(headers, num_actos) when num_actos > 0 do
    headers
    |> Enum.at(0)
    |> String.split(" ")
    |> Enum.at(0)
    |> String.downcase()
  end

  defp get_particion(_headers, _zero_num_actos), do: nil

  defp get_num_actos(headers) do
    headers
    |> Enum.filter(&String.contains?(&1, " "))
    |> Enum.count()
  end

  defp get_apartes(doc) do
    num_apartes = xpath(doc, ~x"count(//seg[not(@next) or contains(@next, 'seg01')])"i)

    versos_aparte = xpath(doc, ~x"count(//seg)"i)

    etiquetas_aparte = xpath(doc, ~x"count(//stage[@type='delivery'])"i)

    %{
      num_apartes: num_apartes,
      versos_aparte: versos_aparte,
      etiquetas_aparte: etiquetas_aparte
    }
  end

  defp get_lineas(doc, num_secciones) do
    # TODO: verso / prosa / versoprosa, pero "intervenciones"?
    tipo_lineas = xpath(doc, ~x"//extent/@ana"s)

    totales = %{
      "verso" => xpath(doc, ~x"count(//l[not(@part) or @part='I'])"i),
      "versoprosa" => xpath(doc, ~x"count(//l[not(@part) or @part='I'])"i),
      "prosa" => xpath(doc, ~x"count(//sp/p)"i)
    }

    total_lineas = totales[tipo_lineas]

    total_fragmentos =
      case tipo_lineas do
        "verso" -> totales["prosa"]
        "prosa" -> totales["verso"]
        _default -> 0
      end

    versos_acto =
      1..num_secciones
      |> Enum.map(&xpath(doc, ~x"count(//div1[#{&1}]//l[not(@part) or @part='I'])"i))

    parrafos_acto =
      1..num_secciones
      |> Enum.map(&xpath(doc, ~x"count(//div1[#{&1}]//p)"i))

    # this is more accurate but doesn't work: num_versos_partidos = xpath(doc, ~x"count(//lg/l[1][@part='F'])"i)
    num_versos_partidos = xpath(doc, ~x"count(//lg/l[@part='F'])"i)

    %{
      tipo_lineas: tipo_lineas,
      total_lineas: total_lineas,
      total_fragmentos: total_fragmentos,
      num_versos_partidos: num_versos_partidos,
      versos_acto: versos_acto,
      parrafos_acto: parrafos_acto
    }
  end

  defp get_estudio_metrica(doc) do
    lg = xpath(doc, ~x"//lg[not(@part) or @part='I']"l)

    lg
    |> Enum.map(fn estrofa ->
      nombre_estrofa = estrofa |> xpath(~x"./@type"s)

      num_verso_inicial = estrofa |> xpath(~x"./l/@n[1]"io)
      num_verso_final = estrofa |> xpath(~x"./l/@n[last()]"io)

      %{
        nombre_estrofa: nombre_estrofa,
        num_verso_inicial: num_verso_inicial,
        num_verso_final: num_verso_final
      }
    end)
    |> Enum.reduce(
      [],
      fn
        estrofa, [] ->
          [estrofa]

        estrofa, acc ->
          [prev_estrofa | rest] = acc

          if estrofa.nombre_estrofa != prev_estrofa.nombre_estrofa do
            [estrofa | acc]
          else
            [%{prev_estrofa | num_verso_final: estrofa.num_verso_final} | rest]
          end
      end
    )
    |> Enum.reverse()
  end

  #
  # Obtiene la agrupación del tipo de estrofas y sus estadisticas (metrica)
  # Returns Metrica map = %{nombre_estrofa, numero_estrofas, numero_versos_estrofas}
  # confirm that code removed at bbfced8728b7032f72c5b8ef4431dc1acdd54401 was previously wrong
  #
  defp get_estrofas(doc) do
    nombres_de_estrofa =
      doc
      |> xpath(~x"//lg[not(@part) or @part='I']/@type"ls)
      |> Enum.uniq()

    nombres_de_estrofa
    |> Enum.map(fn nombre_estrofa ->
      %{
        nombre_estrofa: nombre_estrofa,
        num_estrofas:
          xpath(doc, ~x"count(//lg[not(@part) or @part='I'][@type='#{nombre_estrofa}'])"i),
        num_versos:
          xpath(doc, ~x"count(//lg[not(@part) or @part='I'][@type='#{nombre_estrofa}']/l)"i)
      }
    end)
  end

  defp get_cast(doc) do
    doc
    |> xpath(~x"//castItem[not(contains(@ana,'grupo'))]"l,
      id: ~x"role/@xml:id"s,
      ana: ~x"@ana"s,
      role: ~x"role/text()"s
    )
    |> Enum.map(fn
      %{id: id, ana: "oculto", role: role} -> {"#" <> String.trim(id), "*" <> String.trim(role)}
      %{id: id, ana: _, role: role} -> {"#" <> String.trim(id), String.trim(role)}
    end)
  end

  defp versos_por_personaje(doc, personaje) do
    xpath(doc, ~x"count(//sp[@who='#{personaje}']/lg/l[not(@part)])"i)
  end

  defp versos_partidos_por_personaje(doc, personaje) do
    xpath(doc, ~x"count(//sp[@who='#{personaje}']/lg/l[@part])"i)
  end

  defp intervenciones_por_personaje(doc, personaje) do
    xpath(doc, ~x"count(//sp[@who='#{personaje}'])"i)
  end

  defp get_personajes_intervenciones(doc, cast) do
    personajes =
      doc
      |> xpath(~x"//sp/@who"sl)
      |> Enum.uniq()
      |> Enum.map(&String.trim/1)

    personajes
    |> Enum.map(fn personaje ->
      tipo_intervencion = get_tipo_intervencion(personaje)

      nombre_personaje =
        case tipo_intervencion do
          "unica" -> get_name_from_cast(cast, personaje)
          "multiple" -> get_names_from_cast(cast, String.split(personaje, " "))
        end

      stats_en_conjunto =
        case tipo_intervencion do
          "unica" -> get_stats_en_conjunto(doc, cast, personaje)
          "multiple" -> %{}
        end

      Map.merge(
        %{
          personaje: nombre_personaje,
          tipo: tipo_intervencion,
          versos: versos_por_personaje(doc, personaje),
          versos_partidos: versos_partidos_por_personaje(doc, personaje),
          intervenciones: intervenciones_por_personaje(doc, personaje)
        },
        stats_en_conjunto
      )
    end)
  end

  defp get_stats_en_conjunto(doc, cast, personaje) do
    nombre_personaje = get_name_from_cast(cast, personaje)

    personajes_conjuntos_conteniendo_personaje(cast, personaje)
    |> Enum.reduce(
      # initial acc
      %{
        personaje: nombre_personaje,
        versos_conjunto: 0,
        versos_partidos_conjunto: 0,
        intervenciones_conjunto: 0
      },
      fn _conjunto, acc ->
        %{
          personaje: nombre_personaje,
          versos_conjunto: acc.versos + versos_por_personaje(doc, personaje),
          versos_partidos_conjunto:
            acc.versos_partidos + versos_partidos_por_personaje(doc, personaje),
          intervenciones_conjunto:
            acc.intervenciones + intervenciones_por_personaje(doc, personaje)
        }
      end
    )
  end

  defp get_tipo_intervencion(personaje) do
    count_personaje_split =
      String.split(personaje, " ")
      |> Enum.count()

    case count_personaje_split do
      1 -> "unica"
      len when len > 1 -> "multiple"
    end
  end

  defp personajes_conjuntos_conteniendo_personaje(cast, personaje) do
    cast
    |> Enum.find([], fn
      {^personaje, _role} -> false
      {id_cast, _role} -> personaje in String.split(id_cast, " ")
    end)
  end

  defp get_name_from_cast(cast, personaje) do
    {_id, role} =
      cast
      |> Enum.find(
        {"id_personje_no_encontrado_en_elenco", "personaje_no_encontrado_en_elenco"},
        fn {id, _role} ->
          id == personaje
        end
      )

    role
  end

  defp get_names_from_cast(cast, personajes) do
    personajes
    |> Enum.map_join(", ", &get_name_from_cast(cast, &1))
  end
end
