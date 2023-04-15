# Ozfarium

  Best OzFa gallery ever created

## Install basic dependencies

  `sudo apt update`

  `sudo apt install -y build-essential inotify-tools curl wget git libssh-dev`

## Install PostgreSQL

  `sudo apt install postgresql postgresql-contrib`

  `sudo service postgresql start`

  `sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"`

  `sudo service postgresql restart`

## Install Image processing dependencies

  `sudo apt install -y libjpeg-turbo-progs libglib2.0-dev expat libexif-dev libpng-dev libvips-dev cargo`

  `export PATH="$PATH:~/.cargo/bin"`

  `cargo install oxipng`

## Install Asdf

  [`Installation Guide`](https://asdf-vm.com/guide/getting-started.html#_2-download-asdf)

  Install Asdf plugins:

  `sudo apt-get install unzip dirmngr gpg gawk curl`

  `asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git`

  `asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git`

  `asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git`

  `asdf install` - installs required versions of elixir, erlang and nodejs

## Install JS dependencies

  `cd assets && npm install && cd ..`

## Start Phoenix Server

  `mix deps.get` - installs elixir packages

  `mix deps.compile` - precompiles elixir packages

  `mix ecto.setup` - creates development DB

  `iex -S mix phx.server` - starts local server

  Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

  You will see Auth Bypass on sign-in page

## Testing Telegram Auth [TODO]

  Create telegram bot through Telegram BotFather

  Source its name and token into TELEGRAM_BOT and TELEGRAM_BOT_TOKEN

  Start Ngrok

  Set ngrok domain as bot domain through Telegram BotFather

  Try auth
