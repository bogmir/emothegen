defmodule Emothegen.Play do
  alias Ecto.Changeset

  use TypedStruct

  typedstruct do
    @typedoc "A play"
    field :name, String.t(), enforce: true
    field :play_html_gen, boolean(), default: false
    field :play_stat_gen, boolean(), default: false
    field :play_stat_html_gen, boolean(), default: false
  end

  @types %{
    name: :string,
    play_html_gen: :boolean,
    play_stat_gen: :boolean,
    play_stat_html_gen: :boolean
  }

  def new, do: __struct__()
  def new(opts), do: __struct__(opts)

  def validate(params, list) do
    {new(), @types}
    |> Changeset.cast(params, Map.keys(@types))
    |> Changeset.validate_required([:name, :play_html_gen, :play_stat_gen, :play_stat_html_gen])
    |> Changeset.validate_exclusion(:name, list)
  end
end
