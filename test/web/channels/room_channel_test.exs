defmodule Wwm.Web.RoomChannelTest do
  use Wwm.Web.ChannelCase
  # alias Wwm.Web.RoomChannel
  alias Wwm.Web.UserSocket
  alias Wwm.Events.Events

  @topic "room:lobby"
  @username "Shamshirz"

  setup do
    socket = createUserSocket(%{"username" => @username}, @topic)
    {:ok, socket: socket}
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

  test "user_joined broadcast is send to channel" do
    message = %{username: @username, body: "#{@username} joined!"}

    assert_broadcast "user_joined", ^message
  end

  test "user_joined message is different for the joiner" do
    message = %{username: @username, body: "Welcome #{@username}"}

    assert_push "user_joined", ^message
  end

  test "videoEvents broadcast to everyone", %{socket: socket} do
      event = new_play_event(socket.assigns.username)

      ref = push socket, "action", event
      
      assert_broadcast "action", ^event
      assert_reply ref, :ok, ^event
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

  defp getTime() do
    :os.system_time(:milli_seconds)
  end

  defp new_play_event(username) do
    now = getTime()
    Events.new_video_event("PLAY",
      now,
      now,
      username)
  end
end