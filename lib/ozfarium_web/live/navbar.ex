defmodule OzfariumWeb.Live.Navbar do
  use OzfariumWeb, :live_component


   def render(assigns) do
  user_ozfas = Ozfarium.Users.get_user_ozfas(assigns.current_user.id)
  current_time = NaiveDateTime.utc_now()
  sum = Ozfarium.Users.UserOzfa.sum_of_last_minute_ep_timestamps(user_ozfas, current_time)

  ~H"""
  <div>
    <!-- Your existing navbar HTML code -->

    <!-- Add the following code snippet to the desired location in the navbar -->
    <div class="text-gray-700">
      Sum of EP Timestamps in the Last Minute: <%= sum %>
    </div>

    <!-- Rest of your navbar HTML code -->
  </div>
  """
end



  def sub_links(assigns) do
    ~H"""
      <!-- Current: "bg-gray-300 text-white", Default: "text-gray-300 hover:bg-gray-700 hover:text-white"
      <a href="#" class="bg-gray-300 text-white px-3 py-2 rounded-md text-sm font-medium">Something</a>
      -->
        <a href="/?listed=my_liked" class="text-gray-700 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium">
        Мои озфа
        <.icon name="heart" type="solid" class="h-6 w-6 inline opacity-70 text-rose-500 hover:text-rose-700 drop-shadow-md cursor-pointer" />
      </a>
    """
  end
end
