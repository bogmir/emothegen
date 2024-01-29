defmodule BoundaryTest do
  use ExUnit.Case

  test "detect TEI and generate all" do
    assert [
             %Emothegen.Play{
               play_stat_html_gen: false,
               play_stat_gen: true,
               play_html_gen: true,
               name: "AL0590_LaDiscretaEnamorada"
             }
           ] = Emothegen.Boundary.detect_TEIs_and_generate_all()
  end
end
