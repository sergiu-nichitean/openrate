class DashboardController < ApplicationController
  def index
    @page_title = 'Dashboard'
    @active_menu = :root
  end
end
