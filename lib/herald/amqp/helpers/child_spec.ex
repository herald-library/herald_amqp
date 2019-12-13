defmodule Herald.AMQP.Helpers.ChildSpec do
  @moduledoc false

  alias Supervisor, as: Sup
  alias AMQP.Channel, as: Chan

  defstruct [:queue, :channel]

  @subscriber Herald.AMQP.Subscriber

  @type t :: %__MODULE__{
    queue: String.t(),
    channel: Chan.t()
  }

  @doc """
  Makes a list of child specs.

  Get all queues declared in Router, and
  creates a child `Supervisor.child_spec`
  for each queue.
  """
  @spec get(channel :: Chan.t()) :: list(Sup.child_spec())
  def get(channel) do
    Application.get_env(:herald, :router)
    |> validate_router!()
    |> make_struct(channel)
    |> make_children()
  end

  defp validate_router!(nil) do
    raise """
    Your application don't implement a Router.

    See `Herald` documentation for more details.
    """
  end
  defp validate_router!(router),
    do: router

  defp make_struct(router, channel) do
    apply(router, :routes, [])
    |> Enum.map(fn {queue, _} ->
        %__MODULE__{
          queue: queue,
          channel: channel
        }
    end)
  end

  defp make_children(structs) do
    Enum.map(structs, fn %__MODULE__{queue: queue} = struct ->
      %{
        id: String.to_atom(queue),
        start: {@subscriber, :start_link, [struct]}
      }
    end)
  end
end