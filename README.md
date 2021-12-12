# Ozfarium

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Image processing dependencies

apt install -y build-essential libjpeg-turbo-progs optipng libvips-dev


apt install -y oxipng
cargo install oxipng
export PATH="$PATH:~/.cargo/bin"
