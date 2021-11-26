import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ozfarium, Ozfarium.Repo,
  username: "postgres",
  password: "postgres",
  database: "ozfarium_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ozfarium, OzfariumWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "U8XPwT3tT2d+hkorHNo2HhpNLNyOPTbhK7bKgIctgIGAuZBg5WKQWHSJ5P4UpQ6V",
  server: false

# In test we don't send emails.
config :ozfarium, Ozfarium.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :b2_client,
  backend: B2Client.Backend.Memory,
  bucket: {:system, "ozfarium-test"},
  bucket_url: {:system, "ozfarium-test"},
  key: {:system, "ozfarium-test"},
  app_key: {:system, "ozfarium-test"}
