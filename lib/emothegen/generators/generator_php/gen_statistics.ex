defmodule Emothegen.Generators.GeneratorPhp.GenStatistics do
  use Emothegen.Generators.GeneratorPhp

  @impl true
  def generate_content(xml_path) do
    case Xslt.transform(xsl_template_path(), xml_path) do
      {:ok, content} ->
        {:ok, destination_path(), content}

      error ->
        Logger.error("Unexpected error when transforming with XSLT: #{inspect(error)}")
        error
    end
  end

  defp destination_path, do: Emothegen.config([:files, :statistics_web])
  defp xsl_template_path, do: Emothegen.config([:files, :statistics_template])
end
