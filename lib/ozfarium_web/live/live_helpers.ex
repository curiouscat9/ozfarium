defmodule OzfariumWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers
  import OzfariumWeb.HTMLC.Icon

  @doc """
  Renders a live component inside a modal.

  ## Examples

      <.modal size_classes={"big" || "small"}>
        <.live_component
          module={OzfariumWeb.Live.TagsForm}
          id={@tag.id || :new}
          title={@page_title}
          action={@live_action}
          tag: @tag
        />
      </.modal>
  """
  def modal(assigns) do
    assigns = assign_new(assigns, :size_classes, fn -> "" end)

    ~H"""
    <div id="modal" phx-hook="OpenModal" class="fixed inset-0 w-full h-full z-20 bg-black bg-opacity-50 duration-300 overflow-y-auto"
      phx-window-keydown="close"
      phx-key="escape"
      phx-page-loading>
      <div class={"relative opacity-100 #{@size_classes}"}>
        <div class="relative bg-white shadow-lg text-gray-900 z-20">
          <span phx-click="close" class="absolute top-0 right-0 z-30 p-1 cursor-pointer opacity-80 text-gray-400 hover:text-gray-700">
            <span class="sr-only">Close</span><.icon name="close" class="h-14 w-14 md:h-10 md:w-10" />
          </span>

          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  def select(assigns) do
    ~H"""
    <select name={@name} class={@class} data-selected={@selected}>
      <%= for {name, val} <- @options do %>
        <option value={val} selected={@selected == val}>
          <%= name %>
        </option>
      <% end %>
    </select>
    """
  end
end
