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
      {:ok, ozfa} ->
        send(self(), {:updated_ozfa, %{ozfa: ozfa}})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_ozfa(socket, :new, ozfa_params) do
    case Gallery.create_ozfa(ozfa_params) do
      {:ok, ozfa} ->
        send(self(), {:created_ozfa, %{ozfa: ozfa}})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
