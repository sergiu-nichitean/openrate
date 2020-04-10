class MessageMailer < ApplicationMailer
  def regular_email
    @body = params[:body]
    @footer = params[:footer]
    mail(to: params[:to], from: params[:from], subject: params[:subject])
  end
end
