defmodule Emothegen.Generators.GeneratorPhp.GenStatistics do
  use Emothegen.Generators.GeneratorPhp

  @impl true
  def destination_path, do: Emothegen.config([:files, :statistics_web])

  @impl true
  def xsl_template_path, do: Emothegen.config([:files, :statistics_template])

  @impl true
  def file_extension, do: "html"
end
