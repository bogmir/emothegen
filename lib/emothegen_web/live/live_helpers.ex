defmodule EmothegenWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS

  def icon(assigns) do
    assigns =
      assigns
      |> assign_new(:outlined, fn -> false end)
      |> assign_new(:class, fn -> "w-4 h-4 inline-block" end)
      |> assign_new(:"aria-hidden", fn -> !Map.has_key?(assigns, :"aria-label") end)

    ~H"""
    <%= if @outlined do %>
      <%= apply(Heroicons.Outline, @name, [assigns_to_attributes(assigns, [:outlined, :name])]) %>
    <% else %>
      <%= apply(Heroicons.Solid, @name, [assigns_to_attributes(assigns, [:outlined, :name])]) %>
    <% end %>
    """
  end

  def link(%{navigate: _to} = assigns) do
    assigns = assign_new(assigns, :class, fn -> nil end)

    ~H"""
    <a href={@navigate} data-phx-link="redirect" data-phx-link-state="push" class={@class}>
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  def link(%{patch: to} = assigns) do
    opts = assigns |> assigns_to_attributes() |> Keyword.put(:to, to)
    assigns = assign(assigns, :opts, opts)

    ~H"""
    <%= live_patch @opts do %><%= render_slot(@inner_block) %><% end %>
    """
  end

  def link(%{} = assigns) do
    opts =
      assigns
      |> assigns_to_attributes()
      |> Keyword.put(:to, assigns[:href] || "#")
      |> Keyword.put(:class, "hover:underline")

    assigns = assign(assigns, :opts, opts)

    ~H"""
    <%= Phoenix.HTML.Link.link @opts do %><%= render_slot(@inner_block) %><% end %>
    """
  end

  def message(%{type: "header", text: text} = assigns) do
    ~H"""
    <h1 class="text-gray-900 text-3xl font-bold ml-9"><%= text %></h1>
    """
  end

  def message(%{type: "failed"} = assigns) do
    text = assigns[:text] || "failed"

    ~H"""
    <div class="text-red-900 text-l font-bold"><%= text %></div>
    """
  end

  def flash(%{kind: :error} = assigns) do
    ~H"""
    <%= if live_flash(@flash, @kind) do %>
      <div
        id="flash"
        class="rounded-md bg-red-50 p-4 fixed top-1 right-1 w-96 fade-in-scale z-50"
        phx-click={JS.push("lv:clear-flash") |> JS.remove_class("fade-in-scale", to: "#flash") |> hide("#flash")}
        phx-hook="Flash"
      >
        <div class="flex justify-between items-center space-x-3 text-red-700">
          <.icon name={:exclamation_circle} class="w-5 w-5"/>
          <p class="flex-1 text-sm font-medium" role="alert">
            <%= live_flash(@flash, @kind) %>
          </p>
          <button type="button" class="inline-flex bg-red-50 rounded-md p-1.5 text-red-500 hover:bg-red-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-red-50 focus:ring-red-600">
            <.icon name={:x} class="w-4 h-4" />
          </button>
        </div>
      </div>
    <% end %>
    """
  end

  def flash(%{kind: :info} = assigns) do
    ~H"""
    <%= if live_flash(@flash, @kind) do %>
      <div
        id="flash"
        class="rounded-md bg-green-50 p-4 fixed top-1 right-1 w-96 fade-in-scale z-50"
        phx-click={JS.push("lv:clear-flash") |> JS.remove_class("fade-in-scale") |> hide("#flash")}
        phx-value-key="info"
        phx-hook="Flash"
        data-fadeout-flash={delayed_fadeout_flash()}
      >
        <div class="flex justify-between items-center space-x-3 text-green-700">
          <.icon name={:check_circle} class="w-5 h-5"/>
          <p class="flex-1 text-sm font-medium" role="alert">
            <%= live_flash(@flash, @kind) %>
          </p>
          <button type="button" class="inline-flex bg-green-50 rounded-md p-1.5 text-green-500 hover:bg-green-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-green-50 focus:ring-green-600">
            <.icon name={:x} class="w-4 h-4" />
          </button>
        </div>
      </div>
    <% end %>
    """
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 300,
      transition:
        {"transition ease-in duration-300", "transform opacity-100 scale-100",
         "transform opacity-0 scale-95"}
    )
  end

  # use TailwindCSS to wait 2 seconds before starting transition. Afterwards, send event to server to clear out flash.
  # `lv:clear-flash` will use `phx-value-key` attribute in element to remove flash per type.
  def delayed_fadeout_flash() do
    JS.hide(
      transition:
        {"transition-opacity ease-out delay-2000 duration-1000", "opacity-100", "opacity-0"},
      time: 1000
    )
    |> JS.push("lv:clear-flash")
  end
end
