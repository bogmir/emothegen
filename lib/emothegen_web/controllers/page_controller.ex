defmodule EmothegenWeb.PageController do
  use EmothegenWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
