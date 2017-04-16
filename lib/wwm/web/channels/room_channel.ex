defmodule Wwm.Web.RoomChannel do
  use Phoenix.Channel
  require Logger
  alias Wwm.Events.Events

  @moduledoc """
  As far as I can tell, each socket that connects to this channel (room:*)
  will have a separate process waiting to call these functions.

  So when a socket sends a message to the server, the server will run a
  handle_in function appropriately, and broadcast will push to each socket,
  but you can create an interceptor to do more work before the push, such as
  something socket specific, because it will run for each socket!
  """

  intercept ["user_joined"]

  def join("room:lobby", _message, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info(:after_join, socket) do
    broadcast! socket, "user_joined", Events.joined(socket.assigns.username)
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    Logger.debug"> leave #{inspect reason}"
    :ok
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    messageEvent = Events.message(socket.assigns.username, body)
    broadcast! socket, "new_msg", messageEvent
    {:reply, {:ok, messageEvent}, socket}
  end

  def handle_in("event", %{"type" => "PLAY"}, socket) do
    playEvent = Events.play(socket.assigns.username, :calendar.universal_time())
    broadcast! socket, "event", playEvent
    {:reply, {:ok, playEvent}, socket}
  end

# Ping thoughts
  # def handle_in("ping", _message, socket) do
  #   push socket, "ping", %{username: "SYSTEM", time: :calendar.universal_time()}
  #   {:noreply, socket}
  # end

  # def handle_in("pong", %{"username" => username, "time" => time}, socket) do
  #   IO.puts :calendar.universal_time()
  #   diff = time_diff(time, :calendar.universal_time())
  #   broadcast! socket, "new_msg", %{username: username, body: diff}
  #   {:reply, {:ok, %{msg: diff}}, socket}
  # end
  # defp time_diff(timestamp1, timestamp2) do
  #   abs(timestamp1 - timestamp2)
  # end

  @doc """
  This runs for each socket that is about to output a user_joined message
  We intercept the message then we can edit it based on the something
  specific to this socket - like welcome vs. other user joined
  """
  def handle_out("user_joined", payload, socket) do
    if socket.assigns.username === payload.username do
      push socket, "user_joined", Events.welcome(socket.assigns.username)
      {:noreply, socket}
    else
      push socket, "user_joined", payload
      {:noreply, socket}
    end
  end

  # We can add another to ignore messages sent by yourself
  # And just reploy :ok wot them so you know your message went
  # to the server

end
