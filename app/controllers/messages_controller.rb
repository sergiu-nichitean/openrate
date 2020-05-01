class MessagesController < ApplicationController
  skip_before_action :authenticate_user!

  def tracking_pixel
    sent_message = SentMessage.find_by(id: params[:sent_message_id])
    if sent_message && sent_message.status == 'sent'
      sent_message.update_attribute(:status, 'opened')
      sent_message.message.increment!(:opens)
    end

    send_file 'public/tracking_pixel.jpg', type: 'image/jpeg', disposition: 'inline'
  end

  def track_click
    sent_message = SentMessage.find_by(id: params[:sent_message_id])
    if sent_message && sent_message.status == 'opened'
      sent_message.update_attribute(:status, 'clicked')
      sent_message.message.increment!(:clicks)
    end

    redirect_to params[:url]
  end
end
