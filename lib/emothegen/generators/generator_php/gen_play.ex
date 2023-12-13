defmodule Emothegen.Generators.GeneratorPhp.GenPlay do
  use Emothegen.Generators.GeneratorPhp

  @impl true
  def destination_path, do: Emothegen.config([:files, :tei_web])

  @impl true
  def xsl_template_path, do: Emothegen.config([:files, :tei_template])

  @impl true
  def file_extension, do: "php"
end
