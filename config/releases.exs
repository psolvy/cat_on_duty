import Config

host = System.fetch_env!("HOST")
secret_key_base = System.fetch_env!("SECRET_KEY_BASE")

database_url = System.fetch_env!("DATABASE_URL")
db_pool_size = System.get_env("DB_POOL_SIZE", "18")

config :cat_on_duty, CatOnDutyWeb.Endpoint,
  url: [scheme: "https", host: host, port: 443],
  http: [port: {:system, "PORT"}],
  secret_key_base: secret_key_base

config :cat_on_duty, CatOnDuty.Repo,
  ssl: true,
  url: database_url,
  pool_size: String.to_integer(db_pool_size)

config :nadia,
  token: {:system, "TG_BOT_TOKEN"}
