class ApplicationController < ActionController::Base
  before_action :authenticate_user!, :init_main_menu

  def init_main_menu
    @main_menu = {
      root: 'Dashboard',
      subscribers: 'Subscribers',
      sequences: 'Sequences',
      tags: 'Tags',
      broadcasts: 'Broadcasts',
      settings: 'Settings',
      destroy_user_session: 'Log out'
    }
  end
end
