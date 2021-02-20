# Herald.AMQP

[![Elixir CI](https://github.com/herald-library/herald_amqp/actions/workflows/elixir.yml/badge.svg)](https://github.com/herald-library/herald_amqp/actions/workflows/elixir.yml)

Plugin for use [Herald](https://hexdocs.pm/herald) with AMQP protocol.

To use it, follow these steps:

## Install it

Put in your `mix.exs` and run `mix deps.get`:

```elixir
def deps do
  [
    # ... Another dependencies
    {:herald, "~> 0.1"},
    {:herald_amqp, "~> 0.1"}
  ]
end
```

## Configure

Add `amqp_url` in your configuration, as bellow:

```elixir
config :herald,
  amqp_url: "amqp://my.broker.url"
```

Case your prefer is to use environment variables, configure as bellow:

```elixir
config :herald,
  amqp_url: {:system, "AMQP_URL"}
```

## Start Herald.AMQP

In your application, find the file `application.ex`, and put `Herald.AMQP` in the children list, according the example bellow:

```elixir
defmodule ExampleApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Herald.AMQP, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExampleApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

## Let's go

Now, you only need follow the steps in your [Quick Start](https://hexdocs.pm/herald/) guide and start with Herald!
