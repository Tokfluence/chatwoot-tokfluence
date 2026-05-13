class Bots::SalesReplyJob < ApplicationJob
  queue_as :default

  MODEL = 'claude-sonnet-4-6'.freeze
  HANDOFF_TOKEN = '[[HANDOFF]]'.freeze

  def perform(account_id:, conversation_id:, message_id:, agent_bot_id:)
    account = Account.find(account_id)
    conversation = account.conversations.find(conversation_id)
    bot = AgentBot.find(agent_bot_id)

    return if conversation.resolved?
    return unless latest_message_is?(conversation, message_id)

    reply_text = generate_reply(conversation)
    return if reply_text.blank?

    handoff = reply_text.include?(HANDOFF_TOKEN)
    clean_text = reply_text.gsub(HANDOFF_TOKEN, '').strip
    return if clean_text.blank?

    post_message(bot, conversation, clean_text)
    conversation.toggle_status if handoff && conversation.open?
  end

  private

  def latest_message_is?(conversation, message_id)
    last = conversation.messages.where(message_type: :incoming).order(created_at: :desc).first
    last && last.id == message_id
  end

  def generate_reply(conversation)
    builder = Bots::Sales::PromptBuilder.new(conversation: conversation)
    Llm::Config.initialize!

    chat = RubyLLM.chat(model: MODEL).with_instructions(builder.system_prompt)
    builder.history[0..-2].each { |msg| chat.add_message(role: msg[:role], content: msg[:content]) }
    last = builder.history.last
    return if last.blank?

    chat.ask(last[:content]).content
  rescue StandardError => e
    Rails.logger.error("[Bots::SalesReplyJob] LLM call failed: #{e.class.name} #{e.message}")
    nil
  end

  def post_message(bot, conversation, content)
    Messages::MessageBuilder.new(
      bot,
      conversation,
      { content: content, message_type: 'outgoing' }
    ).perform
  end
end
