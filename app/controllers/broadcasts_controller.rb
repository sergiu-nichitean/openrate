class BroadcastsController < ApplicationController
  before_action :set_broadcast, only: %i[
    show edit update destroy cancel add_filter delete_filter
  ]
  before_action :set_active_menu

  # GET /broadcasts
  # GET /broadcasts.json
  def index
    @sending = current_user.broadcasts.where(status: :to_send)
    @drafts = current_user.broadcasts.where(status: :draft)
    @scheduled = current_user.broadcasts.where(status: :scheduled)
    @sent = current_user.broadcasts.where(status: :sent).order(send_at: :desc)
    @canceled = current_user.broadcasts.where(status: :canceled)
  end

  # GET /broadcasts/1
  # GET /broadcasts/1.json
  def show; end

  # GET /broadcasts/new
  def new
    message = current_user.messages.create(
      from: current_user.default_from,
      audience_size: current_user.subscribers.count
    )
    broadcast = Broadcast.create(
      message_id: message.id,
      user_id: current_user.id,
      status: 'draft'
    )
    redirect_to edit_broadcast_path(broadcast)
  end

  # GET /broadcasts/1/edit
  def edit; end

  # POST /broadcasts
  # POST /broadcasts.json
  # TODO: 6. Send Test
  def create
    @broadcast = Broadcast.new(broadcast_params)

    respond_to do |format|
      if @broadcast.save
        send_or_schedule_broadcast
        format.html { redirect_to broadcasts_path, notice: 'Broadcast was successfully created.' }
        format.json { render :show, status: :created, location: @broadcast }
      else
        format.html { render :new }
        format.json { render json: @broadcast.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /broadcasts/1
  # PATCH/PUT /broadcasts/1.json
  def update
    respond_to do |format|
      if @broadcast.update(broadcast_params)
        @broadcast.message.update_attribute(:audience_size, @broadcast.subscribers.count)
        save_message_rules(@broadcast.message)
        send_or_schedule_broadcast
        format.html { redirect_to broadcasts_path, notice: 'Broadcast was successfully updated.' }
        format.json { render :show, status: :ok, location: @broadcast }
      else
        format.html { render :edit }
        format.json { render json: @broadcast.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /broadcasts/1
  # DELETE /broadcasts/1.json
  def destroy
    @broadcast.destroy
    respond_to do |format|
      format.html { redirect_to broadcasts_url, notice: 'Broadcast was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def cancel
    @broadcast.update_attribute(:status, :canceled)
    redirect_to broadcasts_path
  end

  def filter_value_selector
    @relation = params['relation']
    @operator = params['operator']
    render layout: nil
  end

  def add_filter
    @broadcast.filters.create(
      type: "#{params[:filter_relation].camelize}Filter",
      operator: params[:filter_operator],
      value: params[:filter_value]
    )
    @broadcast.message.update_attribute(:audience_size, @broadcast.subscribers.count)
    redirect_to edit_broadcast_path(@broadcast)
  end

  def delete_filter
    Filter.find(params[:filter_id]).destroy
    redirect_to edit_broadcast_path(@broadcast)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_broadcast
    @broadcast = Broadcast.find(params[:id])
  end

  def set_active_menu
    @active_menu = :broadcasts
  end

  def send_or_schedule_broadcast
    case @broadcast.status
    when 'to_send'
      @broadcast.send_emails
    when 'scheduled'
      @broadcast.schedule_emails
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def broadcast_params
    bp = params.require(:broadcast).permit(
      :send_at, :status,
      message_attributes: %i[from subject content]
    )
    bp[:status] = 'draft' if params[:broadcast][:is_draft] == '1'
    bp[:send_at] = Time.now if params[:broadcast][:status] == 'to_send'
    bp[:user_id] = current_user.id
    bp[:message_attributes][:user_id] = current_user.id
    bp
  end

  def save_message_rules(message)
    save_rule(message, 'open')
    save_rule(message, 'click')
  end

  def save_rule(message, event)
    return unless params[:"#{event}_rule"].present?

    rule_arr = params[:"#{event}_rule"].split('-')
    rule = Rule.find_or_create_by(message_id: message.id, trigger: event)
    rule.action_class = rule_arr[0]
    rule.action_id = rule_arr[1]
    rule.save
  end
end
