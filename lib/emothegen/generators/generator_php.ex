defmodule Emothegen.Generators.GeneratorPhp do
  defmacro __using__(_opts) do
    caller_module = __CALLER__.module

    quote do
      @behaviour Emothegen.Generators.GeneratorPhp

      require Logger

      def generate(file) do
        case Xslt.transform(unquote(caller_module).xsl_template_path(), file) do
          {:ok, generated_php} ->
            destination_file =
              unquote(caller_module).destination_path() <>
                "/" <> extract_file_name(file) <> "." <> unquote(caller_module).file_extension()

            File.write!(destination_file, generated_php)
            Logger.info("The php file #{destination_file} was successfuly generated")

            :ok

          error ->
            Logger.error("Caught error as when getting PHP: #{inspect(error)}")

            error
        end
      rescue
        err ->
          Logger.error("Generating PHP error as it would crash: #{inspect(err)}")
          {:error, :php_generation_error}
      end

      defp extract_file_name(file) do
        file
        |> String.split(["/"])
        |> List.last()
        |> String.replace(".xml", "")
      end
    end
  end

  @callback destination_path() :: binary()
  @callback xsl_template_path() :: binary()
  @callback file_extension() :: binary()
end
