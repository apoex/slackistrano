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
        commits = `git log --pretty=format:'%s %b' #{previous_revision}..#{current_revision}`.split("\n")
        commits.select!{ |c| c[/\[(#\d+)(?:[\s,]*(#\d+))*\]/] }
        commits.map do |commit|
          github_pr_id, tps, name = parse_merge_commit(commit)
          tps, name, github_pr_id = parse_squash_and_merge_commit(commit) unless github_pr_id.present?

          tps.split(',').map do |tp|
            "#{target_process_entity_link(tp.gsub('#',''), name)} #{github_pull_request_link(github_pr_id)}"
          end
        end.join("\n")
      end

      def parse_merge_commit(commit)
        if res = commit.match(/Merge pull request #(\d+).+\[([#\d,\s]*)\]\s*(.+)/)
          res.captures
        else
          [nil, [], nil]
        end
      end

      def parse_squash_and_merge_commit(commit)
        if res = commit.match(/\[([#\d,\s]*)\]\s*(.+)\(#(\d+)\)/)
          res.captures
        else
          [[], nil, nil]
        end
      end

      def target_process_entity_link(entity_id, name)
        "<https://apoexab.tpondemand.com/entity/#{entity_id}|#{tp} - #{name}>"
      end

      def github_pull_request_link(github_pr_id)
        "<https://github.com/#{github_repo}/pull/#{github_pr_id}|Github :octocat:>" if github_pr_id.present?
      end

      def github_repo
        fetch(:repo_url).match(/git@github.com:(.+\/.+).git/).captures.first
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
