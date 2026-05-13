module Bots
  module Sales
    class PromptBuilder
      HISTORY_LIMIT = 12

      SYSTEM_BRIEF = <<~PROMPT.freeze
        You are the Tokfluence sales assistant. You help website visitors in two ways:

        1. Answer product questions clearly and concisely.
        2. Surface upsell opportunities when relevant: highlight higher-tier plans, add-ons, or
           features that fit what the visitor is asking about. Never be pushy. Lead with the
           answer, then suggest the upgrade as a next step if it fits.

        Style:
        - Plain, founder-voice prose. Short sentences.
        - No corporate filler. No em-dashes.
        - If you do not know the answer, say so and offer to connect a human teammate.
        - If the visitor asks for a human, agrees to a demo, or shares an objection you cannot
          handle, end your reply with the literal token [[HANDOFF]] so the system can flag the
          conversation for a teammate.

        Product context (placeholder, replace once we have real copy):
        - Tokfluence is an influencer marketing platform.
        - Plans: Starter, Growth, Scale. Growth is the most popular for active campaigns.
        - Common FAQs: pricing, supported platforms, onboarding time, contract length.
      PROMPT

      def initialize(conversation:)
        @conversation = conversation
      end

      def system_prompt
        SYSTEM_BRIEF
      end

      def history
        @conversation.messages
                     .where(private: false)
                     .where.not(content: [nil, ''])
                     .order(created_at: :desc)
                     .limit(HISTORY_LIMIT)
                     .reverse
                     .map { |msg| { role: role_for(msg), content: msg.content.to_s } }
      end

      private

      def role_for(message)
        message.incoming? ? :user : :assistant
      end
    end
  end
end
