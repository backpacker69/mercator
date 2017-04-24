# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

config :atlas,
  db_dir: "db",
  reload_interval: 20*1000,
  start_height: -200, # First block to parse (negative means relative to last block at startup)
  batch_rpc: true # Compile time constant, no effect when changed without recompiling

import_config "#{Mix.env}.exs"
