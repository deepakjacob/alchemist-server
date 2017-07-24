Code.require_file "../test_helper.exs", __DIR__
Code.require_file "../../lib/server/socket.exs", __DIR__

defmodule Alchemist.Server.SocketTest do
  use ExUnit.Case

  alias Alchemist.Server.Socket, as: ServerSocket

  setup do
    sock_id = :erlang.system_time()
    {:ok, server_pid} = ServerSocket.start([env: "dev", socket_file: "/tmp/alchemist-server-#{sock_id}.sock"])
    Process.sleep(100)
    socket_file = String.to_charlist("/tmp/alchemist-server-#{sock_id}.sock")
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect({:local, socket_file}, 0, opts)
    {:ok, socket: socket}
  end

  test "server reply ping", %{socket: socket} do
    assert send_and_recv(socket, "PING\n", 2) == "PONG\nEND-OF-PING\n"
  end

  defp send_and_recv(socket, command, num_lines) do
    :ok = :gen_tcp.send(socket, command)
    result = for _ <- 1..num_lines do
      {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
      data
    end
    Enum.join(result)
  end
end
