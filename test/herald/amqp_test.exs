defmodule Herald.AMQPTest do
  use ExUnit.Case
  doctest Herald.AMQP

  test "greets the world" do
    assert Herald.AMQP.hello() == :world
  end
end
