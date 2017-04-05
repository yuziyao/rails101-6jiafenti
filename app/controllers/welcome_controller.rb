class WelcomeController < ApplicationController
  def index
    flash[:notice] = "Good Moring"
  end
end
