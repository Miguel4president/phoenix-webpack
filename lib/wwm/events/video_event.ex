defmodule Wwm.Events.VideoEvent do
  @moduledoc """
  Provides a struct describing the change in video state
  """

  @enforce_keys [:type, :time, :initiator]
  defstruct [:type, :time, :initiator]
end
