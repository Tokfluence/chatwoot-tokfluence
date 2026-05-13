class Internal::Bots::SalesWebhookController < ActionController::API
  before_action :load_agent_bot
  before_action :verify_signature

  def create
    return head :ok unless reply_trigger?

    Bots::SalesReplyJob.perform_later(
      account_id: payload.dig(:account, :id),
      conversation_id: payload.dig(:conversation, :id),
      message_id: payload[:id],
      agent_bot_id: @agent_bot.id
    )
    head :ok
  end

  private

  def payload
    @payload ||= JSON.parse(request_body, symbolize_names: true)
  rescue JSON::ParserError
    {}
  end

  def request_body
    @request_body ||= request.body.read
  end

  def load_agent_bot
    @agent_bot = AgentBot.find_by(id: params[:bot_id])
    head :not_found and return unless @agent_bot
  end

  def verify_signature
    signature = request.headers['X-Chatwoot-Signature'].to_s.sub(/\Asha256=/, '')
    timestamp = request.headers['X-Chatwoot-Timestamp'].to_s
    expected = OpenSSL::HMAC.hexdigest('SHA256', @agent_bot.secret.to_s, "#{timestamp}.#{request_body}")
    head :unauthorized unless ActiveSupport::SecurityUtils.secure_compare(signature, expected)
  end

  def reply_trigger?
    payload[:event] == 'message_created' &&
      payload[:message_type] == 'incoming' &&
      !payload[:private]
  end
end
