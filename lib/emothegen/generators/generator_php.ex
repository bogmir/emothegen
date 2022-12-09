defmodule Emothegen.Generators.GeneratorPhp do
  defmacro __using__(_opts) do
    caller_module = __CALLER__.module

    quote do
      @behaviour Emothegen.Generators.GeneratorPhp

      require Logger

      def generate(file) do
        case unquote(caller_module).generate_content(file) do
          {:ok, destination_dir, generated_php} ->
            destination_file = destination_dir <> "/" <> extract_file_name(file) <> ".php"

            File.write!(destination_file, generated_php)
            Logger.info("The php file #{destination_file} was successfuly generated")

            :ok

          error ->
            error
        end
      rescue
        e in RuntimeError -> e
      end

      defp extract_file_name(file) do
        file
        |> String.split(["/"])
        |> List.last()
        |> String.replace(".xml", "")
      end
    end
  end

  @callback generate_content(binary) :: {:error, <<_::64, _::_*8>>} | {:ok, binary, binary}
end
