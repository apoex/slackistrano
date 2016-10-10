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
        {
          attachments: [{
            color: 'good',
            title: "#{name} deployed :rocket:",
            fields: [{
              title: 'Environment',
              value: stage,
              short: true
            }, {
              title: 'Branch',
              value: branch,
              short: true
            }, {
              title: 'Deployer',
              value: deployer,
              short: true
            }, {
              title: 'Time',
              value: elapsed_time,
              short: true
            }],
            fallback: super[:text]
          }]
        }
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
