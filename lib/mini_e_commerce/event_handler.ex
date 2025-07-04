defmodule MiniECommerce.EventHandler do
  @moduledoc """
  Centralized place for Publishing and subscribing for the event topics, messages
  """
  alias Phoenix.PubSub

  @doc """
  broadcasts the messages to specific topic
  """
  def broadcast_event(pubsub, topic_name, message) do
    PubSub.broadcast(pubsub, topic_name, message)
  end

  @doc """
  subscribes to the specific topic and listen for the updates
  """
  def subscribe_event(pubsub, topic_name) do
    PubSub.subscribe(pubsub, topic_name)
  end
end
