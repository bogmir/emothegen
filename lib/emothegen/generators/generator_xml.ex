defmodule Emothegen.Generators.GeneratorXml do
  defmacro __using__(_opts) do
    quote do
      @behaviour Emothegen.Generators.GeneratorXml

      require Logger

      def generate(file) do
        with {:ok, file_contents} <- File.read(file),
             {:ok, destination_dir, generated_xml} <- generate_content(file_contents) do
          destination_file = destination_dir <> "/" <> extract_file_name_with_ext(file)

          File.write!(destination_file, generated_xml)
          Logger.info("The xml file #{destination_file} was successfuly generated")

          :ok
        end
      end

      defp extract_file_name_with_ext(file) do
        file
        |> String.split(["/"])
        |> List.last()
      end
    end
  end

  @callback generate_content(binary) :: {:error, <<_::64, _::_*8>>} | {:ok, binary, binary}
end
