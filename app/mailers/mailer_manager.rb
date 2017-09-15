require 'net/http'

class MailerManager
  include ActiveModel::Model

  attr_accessor :sender, :sender_email, :subject, :recipients, :template_name, :template_params, :reply_to, :attachments

  def initialize(*args)
    super
    @token = ENV['MENSAJES_API_TOKEN']
    @host  = ENV['MENSAJES_API_URL']
    @port  = ENV['MENSAJES_API_PORT']
  end

  def call
    request = Net::HTTP::Post.new("/api/messages")

    request.content_type = 'application/json'
    request.body = message.to_json
    request['authorization'] = "Token token=#{@token}"

    Net::HTTP.new(@host, @port).request(request)
  end

  private

  def message
    {
      sender:          sender,
      sender_email:    sender_email,
      subject:         subject,
      recipients:      recipients,
      template_name:   template_name,
      template_params: template_params || {},
      reply_to:        reply_to,
      attachments:     attachments     || []
    }
  end
end
