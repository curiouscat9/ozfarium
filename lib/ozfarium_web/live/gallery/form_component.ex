defmodule OzfariumWeb.Live.Gallery.FormComponent do
  use OzfariumWeb, :live_component

  alias Ozfarium.Gallery

  @impl true
  def update(%{ozfa: ozfa} = assigns, socket) do
    changeset = Gallery.change_ozfa(ozfa)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"ozfa" => ozfa_params}, socket) do
    changeset =
      socket.assigns.ozfa
      |> Gallery.change_ozfa(ozfa_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"ozfa" => ozfa_params}, socket) do
    save_ozfa(socket, socket.assigns.action, ozfa_params)
  end

  defp save_ozfa(socket, :edit, ozfa_params) do
    case Gallery.update_ozfa(socket.assigns.ozfa, ozfa_params) do
      {:ok, _ozfa} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ozfa updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_ozfa(socket, :new, ozfa_params) do
    # 0..1000 |> Enum.each(fn i -> Gallery.create_ozfa(%{type: "text", content: "ozfa ##{i}"}) end)

    case Gallery.create_ozfa(ozfa_params) do
      {:ok, _ozfa} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ozfa created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
