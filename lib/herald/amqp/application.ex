defmodule Herald.AMQP.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Herald.AMQP.Worker.start_link(arg)
      # {Herald.AMQP.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Herald.AMQP.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
