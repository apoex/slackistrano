module Slackistrano
  module Messaging
    class Apoex < Base

      def payload_for_updating
        super
      end

      def payload_for_reverting
        super
      end

      def payload_for_updated
        super
      end

      def payload_for_reverted
        super
      end

      def payload_for_failed
        super
      end

      def channels_for(action)
        super
      end

      def deployer
        `git config user.name`.strip || super
      end

    end
  end
end
