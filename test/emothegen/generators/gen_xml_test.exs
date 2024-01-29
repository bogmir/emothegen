defmodule Generators.GenXmlStatisticsTest do
  use ExUnit.Case
  alias Emothegen.Generators.GeneratorXml.GenXmlStatistics

  test "parse xml for Statistics" do
    dir_path = Emothegen.config([:files, :tei_dir])
    file_name = "/AL0590_LaDiscretaEnamorada.xml"
    assert :ok = GenXmlStatistics.generate(dir_path <> file_name)
  end
end
