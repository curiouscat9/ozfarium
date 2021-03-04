defmodule Ozfarium.Repo do
  use Ecto.Repo,
    otp_app: :ozfarium,
    adapter: Ecto.Adapters.Postgres
end
