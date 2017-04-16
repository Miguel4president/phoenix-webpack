defmodule Wwm.Events.Events do
    alias Wwm.Events.VideoEvent

    def play(time, username) do
        %VideoEvent{type: "PLAY", time: time, initiator: username}
    end

		def message(username, content) do
			%{sender: username, body: createBody(username, content)}
		end

		def joined(username) do
			%{username: username, body: "#{username} joined!"}
		end

		def welcome(username) do
			%{username: username, body: "Welcome #{username}"}
		end

		defp createBody(username, body) do
     "[#{username}] #{body}"
  	end
end
