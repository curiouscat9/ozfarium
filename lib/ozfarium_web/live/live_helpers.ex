defmodule OzfariumWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `OzfariumWeb.ModalComponent` component.

  The rendered modal sends modal_closed event when it is closed.

  ## Examples

      <%= live_modal OzfariumWeb.OzfaLive.FormComponent,
        id: @ozfa.id || :new,
        action: @live_action,
        ozfa: @ozfa %>
  """
  def live_modal(component, opts) do
    modal_opts = [id: :modal, component: component, size_classes: opts[:size_classes], opts: opts]
    live_component(OzfariumWeb.ModalComponent, modal_opts)
  end
end
