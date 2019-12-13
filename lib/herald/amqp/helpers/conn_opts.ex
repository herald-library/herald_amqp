defmodule Herald.AMQP.Helpers.ConnOpts do
  @moduledoc false

  @valid_keys [
    :host,
    :port,
    :username,
    :password,
    :frame_max,
    :heartbeat,
    :ssl_options,
    :channel_max,
    :virtual_host,
    :socket_options,
    :client_properties,
    :connection_timeout
  ]

  @type conn_opts :: [
    host: String.t(),
    port: String.t(),
    username: String.t(),
    password: String.t(),
    frame_max: non_neg_integer(),
    heartbeat: non_neg_integer(),
    ssl_options: term(),
    channel_max: non_neg_integer(),
    virtual_host: String.t(),
    socket_options: list(any()),
    client_properties: list(any()),
    connection_timeout: non_neg_integer()
  ]

  @doc """
  Returns `conn_opts` according `AMQP.Connection.open/2`
  requirements.

  It loads application environment and converts the value of
  `amqp_url` into a Keyword according AMQP library requirements.

  For more details, see `AMQP.Connection.open/2`.
  """
  @spec get() :: conn_opts
  def get() do
    case Application.get_env(:herald, :amqp_url) do
      {:system, environment} ->
        System.get_env(environment) || "amqp://localhost"

      amqp_url ->
        amqp_url || "amqp://localhost"
    end
    |> URI.parse()
    |> conn_opts_from_uri()
  end

  defp conn_opts_from_uri(%URI{} = info) do
    Map.from_struct(info)
    |> Enum.reduce(Keyword.new(), fn {key, value}, acc ->
      put_conn_opts(acc, key, value)
    end)
    |> Keyword.take(@valid_keys)
  end
  
  defp put_conn_opts(info, _key, nil),
    do: info
  defp put_conn_opts(info, :userinfo, value) do
    case String.split(value, ":") do
      [user, ""] ->
        Keyword.put(info, :username, user)

      ["", password] ->
        Keyword.put(info, :password, password)

      [user, password] ->
        info
        |> Keyword.put(:username, user)
        |> Keyword.put(:password, password)
    end
  end
  defp put_conn_opts(info, key, value) do
    Keyword.put(info, key, value)
  end
end