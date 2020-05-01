class WebhooksController < ApplicationController
  before_action :set_user, only: :add_subscriber
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  layout nil

  def add_subscriber
    set_user
    if params[:email].present? && Devise.email_regexp.match(params[:email])
      if check_existing_subscriber
        render json: { notice: 'A subscriber with this email already exists.' }
      else
        create_subscriber
      end
    else
      render json: { error: 'Missing or invalid email.' }
    end
  end

  private

  def set_user
    if params[:api_key].present?
      unless (@user = User.find_by(api_key: params[:api_key]))
        render json: { error: 'Invalid API key.' }
      end
    else
      render json: { error: 'Mising API key.' }
    end
  end

  def create_subscriber
    @user.subscribers.create(
      first_name: params[:first_name],
      last_name: params[:last_name],
      email: params[:email],
      tags: build_tags
    )

    render json: { success: 'Subscriber created successfully.' }
  end

  def check_existing_subscriber
    return true if @user.subscribers.where(email: params[:email]).first

    false
  end

  def build_tags
    return [] unless params[:tags]

    tags = []
    params[:tags].split(',').map(&:strip).each do |tag_name|
      tags << Tag.find_or_create_by(name: tag_name, user_id: @user.id)
    end
    tags
  end
end
