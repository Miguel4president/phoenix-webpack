defmodule Wwm.Web.RoomChannel do
  use Phoenix.Channel
  require Logger

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def terminate(reason, _socket) do
    Logger.debug"> leave #{inspect reason}"
    :ok
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast! socket, "new_msg", %{body: "[#{socket.assigns.username}] #{body}"}
    {:reply, {:ok, %{body: "[#{socket.assigns.username}] #{body}"}}, socket}
  end

  def handle_in("new_msg", %{"body" => "PLAY"}, socket) do
    broadcast! socket, "new_msg", %{body: "PLAY"}
    {:reply, {:ok, %{body: "PLAY"}}, socket}
  end

  def handle_in("ping", _message, socket) do
    push socket, "ping", %{username: "SYSTEM", time: :calendar.universal_time()}
    {:noreply, socket}
  end

  def handle_in("pong", %{"username" => username, "time" => time}, socket) do
    IO.puts :calendar.universal_time()
    diff = time_diff(time, :calendar.universal_time())
    broadcast! socket, "new_msg", %{username: username, body: diff}
    {:reply, {:ok, %{msg: diff}}, socket}
  end

  # def handle_in("new_msg", %{"body" => body}, socket) do
  #   broadcast! socket, "new_msg", %{body: body}
  #   {:noreply, socket}
  # end

  def handle_out("new_msg", payload, socket) do
    IO.puts "Handling out now"
    IO.inspect payload
    IO.inspect socket
    push socket, "new_msg", payload
    {:noreply, socket}
  end

  defp time_diff(timestamp1, timestamp2) do
    abs(timestamp1 - timestamp2)
  end

end
