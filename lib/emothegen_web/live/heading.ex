defmodule EmothegenWeb.Heading do
  use Phoenix.Component

  def one(assigns) do
    ~H"""
    <h1 class="text-gray-900 text-3xl font-bold ml-9"><%= @message %></h1>
    """
  end

  def two(assigns) do
    ~H"""
    <h1><%= @message %></h1>
    """
  end
end
