class HomeController < ApplicationController
  def index
    if user_signed_in?
      # Logged-in users go directly to their resort dashboard
      redirect_to resorts_path
    end
    # Non-logged-in users see the landing page (no API calls)
  end
end
