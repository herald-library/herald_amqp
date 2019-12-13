defmodule Herald.AMQP do
  @moduledoc false

  use AMQP
  use GenServer

  require Logger

  alias Herald.Pipeline
  alias Herald.AMQP.Helpers.ConnOpts

  @conn_max_attempts 5

  @doc false
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, [
      name: __MODULE__
    ])
  end

  @doc false
  def init(:ok) do
    connect_with_broker()
    |> queue_subscription()
  end

  @doc false
  def handle_info({:basic_consume_ok, _}, channel) do
    {:noreply, channel}
  end

  @doc false
  def handle_info({:basic_cancel, _}, channel) do
    {:stop, :normal, channel}
  end

  @doc false
  def handle_info({:basic_cancel_ok, _}, channel) do
    {:noreply, channel}
  end

  @doc false
  def handle_info({:basic_deliver, payload, %{consumer_tag: tag, routing_key: queue}}, channel) do
    Logger.debug("Received message with payload #{payload}")

    case Pipeline.run(queue, payload) do
      %Pipeline{perform: :ack} ->
        Basic.ack(channel, tag)

      %Pipeline{perform: :requeue} ->
        Basic.reject(channel, tag, requeue: true)

      %Pipeline{perform: :delete} ->
        Basic.reject(channel, tag, requeue: false)
    end

    {:noreply, channel}
  end

  defp connect_with_broker(attempt \\ 1) do
    ConnOpts.get()
    |> AMQP.Connection.open()
    |> case do
      {:ok, %{pid: pid} = conn} -> 
        Process.link(pid)

        AMQP.Channel.open(conn)

      {:error, reason} ->
        if attempt > @conn_max_attempts do
          Process.sleep(300)

          attempt
          |> Kernel.+(1)
          |> connect_with_broker()
        else
          {:error, reason}
        end
    end
  end

  defp queue_subscription({{:error, reason}}),
    do: {:error, reason}
  defp queue_subscription({:ok, %Channel{} = channel}),
    do: queue_subscription(channel)
  defp queue_subscription(%Channel{} = channel) do
    Application.get_env(:herald, :router)
    |> apply(:routes, [])
    |> Enum.each(fn {queue, _} ->
      Queue.declare(channel, queue, durable: true)

      Basic.qos(channel, prefetch_count: 10)
      Basic.consume(channel, queue)
    end)
    
    {:ok, channel}
  end
end
