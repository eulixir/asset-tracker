defmodule AssetTracker.Application do
  use Application

  alias AssetTracker.Database

  def start(_type, _args) do
    Database.init()

    children = []

    opts = [strategy: :one_for_one, name: AssetTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
