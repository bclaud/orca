import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
# config :orca, Orca.Repo,
#   database: "orca_test#{System.get_env("MIX_TEST_PARTITION")}",
#   socket_dir: System.get_env("PGHOST"),
#   adapter: Ecto.Adapters.Postgres,
#   pool: Ecto.Adapters.SQL.Sandbox,
#   pool_size: 10

test_repo_connection_opts =
  case System.get_env("NIX_BUILD_TEST") do
    nil ->     [
      username: "postgres",
      password: "postgres",
      hostname: "localhost",
      database: "orca_test#{System.get_env("MIX_TEST_PARTITION")}",
      pool: Ecto.Adapters.SQL.Sandbox,
      pool_size: 10
    ]
    _ ->      [
       username: "postgres",
       socket_dir: "/build/run/postgresql",
       database: "orca_test#{System.get_env("MIX_TEST_PARTITION")}",
       pool: Ecto.Adapters.SQL.Sandbox,
       pool_size: 10
     ] 
  end

config :orca, Orca.Repo, test_repo_connection_opts

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :orca, OrcaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "YQVbubKQUoYmFnrw1cjDJRs3aZBQhLuRZL2ovsSPWDTBZn7lbc9qjDqxjzyKv1FY",
  server: false

# In test we don't send emails.
config :orca, Orca.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
