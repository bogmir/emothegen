defmodule Emothegen.Repo do
  use Ecto.Repo,
    otp_app: :emothegen,
    adapter: Ecto.Adapters.Postgres
end
