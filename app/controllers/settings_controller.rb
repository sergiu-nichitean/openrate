class SettingsController < ApplicationController
  before_action :init_menu

  def index; end

  def save
    if current_user.update(settings_params)
      redirect_to settings_path, notice: 'Settins were successfully updated.'
    else
      render :index
    end
  end

  private

  def init_menu
    @page_title = 'Settings'
    @active_menu = :settings
  end

  def settings_params
    params.require(:user).permit(
      :smtp_address, :smtp_port, :smtp_user_name, :smtp_password,
      :default_from, :company_name, :email_footer
    )
  end
end
