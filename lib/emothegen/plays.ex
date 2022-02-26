defmodule Emothegen.Plays do
  alias Emothegen.Play

  def new do
    []
  end

  def add(plays, name, status) do
    new_play = struct(Play, name: name, status: status)
    [new_play | plays]
  end
end
