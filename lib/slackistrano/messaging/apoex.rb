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
            }, {
              title: 'Stories',
              value: stories,
              short: false
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

      def stories
        commits = `git log --pretty=format:%s%n%b #{previous_revision}..#{current_revision}`.split("\n")
        commits.select!{ |c| c[/\[(#\d+)(?:[\s,]*(#\d+))*\]/] }
        commits.map do |commit|
          tps, name = commit.match(/\[([#\d,\s]*)\]\s*(.+)/).captures
          tps.split(',').map do |tp|
            "#{tp} - #{name}, <a href='https://apoexab.tpondemand.com/entity/#{tp.gsub('#','')}'>TP</a>"
          end
        end.join("\n")
      end

      def current_revision
        fetch(:current_revision)
      end

      def previous_revision
        fetch(:previous_revision)
      end
    end
  end
end
