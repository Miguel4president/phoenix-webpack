defmodule Wwm.Web.RoomChannelTest do
  use Wwm.Web.ChannelCase
  alias Wwm.Web.RoomChannel
  alias Wwm.Web.UserSocket

  @lobby "room:lobby"

  setup do
    {:ok, socket: createUserSocket(%{"username" => "shamshirz"}, @lobby)}
  end

  test "new socket connections without a username default to anonymous" do
      params = %{}

      socket = createUserSocket(params, @lobby)

      assert socket.assigns.username == "anonymous"
  end

  test "new socket connections can send a username param and it's mapped to assigns" do
      params = %{"username" => "shamshirz"}
      
      socket = createUserSocket(params, @lobby)


      assert socket.assigns.username == "shamshirz"
  end

  test "new_msg reply prepends message with username", %{socket: socket} do
      message = "Welcome to OASIS"
      body = createBody(socket, message)

      ref = push socket, "new_msg", %{username: socket.assigns.username, body: message}
      
      assert_broadcast "new_msg", %{body: ^body}
      assert_reply ref, :ok, %{body: ^body}
  end

  test "new_msg broadcast prepends message with username'", %{socket: socket} do
    message = "Welcome to OASIS"
    body = createBody(socket, message)

    broadcast_from! socket, "new_msg", %{body: body}

    assert_push "new_msg", %{body: ^body}
  end

# Helper fxns
  defp createBody(socket, body) do
     "[#{socket.assigns.username}] #{body}" 
  end

  defp createUserSocket(connection_params, topic) do
    {:ok, socket} = connect(UserSocket, connection_params)
    {:ok, _, socket} = subscribe_and_join(socket, topic) 
    socket
  end
end