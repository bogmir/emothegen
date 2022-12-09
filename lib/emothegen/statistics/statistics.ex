defmodule Emothegen.Statistics do
  @moduledoc """
  A struct representing statistics.
  """

  use TypedStruct

  typedstruct do
    @typedoc "Statistics for one play"

    field(:titulo_obra, String.t(), enforce: true)
    field(:titulo_archivo, String.t(), enforce: true)
    field(:idioma, String.t(), enforce: true)
    field(:estructura, map(), enforce: true)
    field(:lineas, map(), enforce: true)
    field(:acotaciones, String.t(), enforce: true)
    field(:apartes, String.t(), enforce: true)
    field(:intervenciones, map())
    field(:estudio_metrica, map())
    field(:estrofas, map())
  end
end
