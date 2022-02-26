defmodule Emothegen.Generators.GeneratorPhp.GenPlay do
  use Emothegen.Generators.GeneratorPhp

  @impl true
  def generate_content(xml_path) do
    case Xslt.transform(xsl_template_path(), xml_path) do
      {:ok, content} ->
        {:ok, destination_path(), content}

      error ->
        error
    end
  end

  defp destination_path, do: Emothegen.config([:files, :tei_web])
  defp xsl_template_path, do: Emothegen.config([:files, :tei_template])
end
