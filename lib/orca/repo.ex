defmodule Orca.Repo do
  use Ecto.Repo,
    otp_app: :orca,
    adapter: Ecto.Adapters.Postgres
end
