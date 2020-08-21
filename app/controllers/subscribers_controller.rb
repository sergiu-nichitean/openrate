class SubscribersController < ApplicationController
  before_action :set_subscriber, only: [:show, :edit, :update, :destroy]
  before_action :set_subscriber_by_token, only: %i[
    unsubscribe cancel_unsubscribe submit_unsubscribe
  ]
  skip_before_action :authenticate_user!, only: %i[
    unsubscribe cancel_unsubscribe submit_unsubscribe
  ]
  layout 'empty_center', only: %i[unsubscribe cancel_unsubscribe submit_unsubscribe]

  # GET /subscribers
  # GET /subscribers.json

  # TODO: 0. click track not working with get vars
  # TODO: 0b. change broadcast status when sidekiq job is done
  # TODO: 1. Pagination for subscribers
  # TODO: 2. Filter subscribers (flow from broadcasts, maybe drop custom fields for now)
  # TODO: 3. Bulk actions: add tag, remove tag, delete, export
  def index
    @subscribers = current_user.subscribers
    @active_menu = :subscribers
  end

  # GET /subscribers/1
  # GET /subscribers/1.json
  def show
  end

  # GET /subscribers/new
  def new
    @subscriber = Subscriber.new
  end

  # GET /subscribers/1/edit
  def edit
  end

  # POST /subscribers
  # POST /subscribers.json
  def create
    @subscriber = Subscriber.new(subscriber_params)

    respond_to do |format|
      if @subscriber.save
        format.html { redirect_to @subscriber, notice: 'Subscriber was successfully created.' }
        format.json { render :show, status: :created, location: @subscriber }
      else
        format.html { render :new }
        format.json { render json: @subscriber.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subscribers/1
  # PATCH/PUT /subscribers/1.json
  def update
    respond_to do |format|
      if @subscriber.update(subscriber_params)
        format.html { redirect_to @subscriber, notice: 'Subscriber was successfully updated.' }
        format.json { render :show, status: :ok, location: @subscriber }
      else
        format.html { render :edit }
        format.json { render json: @subscriber.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscribers/1
  # DELETE /subscribers/1.json
  def destroy
    @subscriber.destroy
    respond_to do |format|
      format.html { redirect_to subscribers_url, notice: 'Subscriber was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def unsubscribe
    @page_title = 'Unsubscribe from emails'
    return unless @subscriber

    @page_title = "Unsubscribe from emails - #{@subscriber.user.company_name}"
    @message_id = params[:message_id]
  end

  def cancel_unsubscribe
    @page_title = "Canceled unsubscribe - #{@subscriber.user.company_name}"
  end

  def submit_unsubscribe
    @page_title = "Unsubscribed successfully - #{@subscriber.user.company_name}"
    if (message = Message.find_by(id: params[:message_id]))
      message.increment!(:unsubscribes)
      @subscriber.destroy
    else
      redirect_to '/'
    end
  end

  def import; end

  def submit_import
    if params[:subscriber_feed]
      validate_and_start_import(params[:subscriber_feed].tempfile.path)
    else
      redirect_to import_subscribers_path, alert: 'Please attach a valid CSV file.'
    end
  end

  def bulk_remove; end

  def submit_bulk_remove
    if params[:emails].present?
      bulk_remove_by_emails(params[:emails])
    else
      redirect_to bulk_remove_subscribers_path, alert: 'Please enter at least one email address.'
    end
  end

  def import_status
    @import = SubscriberImport.find(params[:id])
    respond_to do |format|
      format.html { render :import_status }
      format.json do
        render json: {
          status: @import.status,
          errors: @import.error_messages
        }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_subscriber
    @subscriber = Subscriber.find(params[:id])
  end

  def set_subscriber_by_token
    @subscriber = Subscriber.find_by(unsubscribe_token: params[:token])
  end

  def bulk_remove_by_emails(raw_emails)
    emails = raw_emails.lines.map(&:strip)
    unless validate_bulk_emails(emails)
      redirect_to(
        bulk_remove_subscribers_path, alert: 'You have entered one or more invalid emails.'
      )
      return
    end
    redirect_to subscribers_url, notice: Subscriber.bulk_remove_by_emails(emails, current_user.id)
  end

  def validate_bulk_emails(emails)
    return true if emails.reject { |email| Devise.email_regexp.match(email) }.empty?

    false
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def subscriber_params
    params.require(:subscriber).permit(:first_name, :last_name, :email, :user_id)
  end

  def validate_and_start_import(file_path)
    import = current_user.subscriber_imports.create(file_path: file_path)
    if (error = import.file_validation_error)
      redirect_to import_subscribers_path, alert: error
    else
      import.start_import
      redirect_to action: :import_status, id: import.id
    end
  end
end
