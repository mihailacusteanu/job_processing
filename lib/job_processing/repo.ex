defmodule JobProcessing.Repo do
  use Ecto.Repo,
    otp_app: :job_processing,
    adapter: Ecto.Adapters.Postgres
end
