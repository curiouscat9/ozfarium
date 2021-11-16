defmodule OzfariumWeb.HTMLC.Tabs do
  use Phoenix.Component

  def live_tabs(assigns) do
    ~H"""
      <div class={"grid grid-cols-#{Enum.count(assigns.tabs)} justify-items-stretch"}>
        <%= for {target, name} <- assigns.tabs do %>
          <.live_tab
            name={name}
            target={target}
            selected={assigns.selected}
            phx_action={assigns.phx_action}
            phx_target={assigns.phx_target} />
        <% end %>
      </div>
    """
  end

  def live_tab(assigns) do
    ~H"""
      <div
        class={"text-center px-4 py-2 rounded-md rounded-b-none text-sm font-medium #{
          if assigns.target == assigns.selected do
            "border border-gray-300 border-b-transparent text-gray-800"
          else
            "border-b border-gray-300 text-gray-500 hover:bg-gray-50 cursor-pointer"
          end
        }"}
        phx-click={assigns.phx_action}
        phx-value-target={assigns.target}
        phx-target={assigns.phx_target} >
       <%= assigns.name %>
      </div>
    """
  end
end
