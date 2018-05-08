module Slackistrano
  module Messaging
    class Apoex < Base
      include Capistrano::Doctor::OutputHelpers

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
            title: "#{username} deployed :rocket:",
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
              title: 'Pull requests',
              value: pull_requests,
              short: false
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
        deployer_name_from_git.empty? ? super : deployer_name_from_git
      end

      def deployer_name_from_git
        @deplyer_name ||= %x(git config user.name).strip
      end

      def pull_requests
        merge_commits.map do |commit|
          github_pr_id, type, name = parse_merge_commit(commit)

          "#{name} #{github_pull_request_link(github_pr_id)}"
        end.join("\n")
      rescue StandardError => e
        warning 'Slackistrano: Error finding pull requests:'
        warning e.message
        warning e.backtrace.join("\n")
        'Error finding pull requests'
      end

      def stories
        story_commits.map do |commit|
          github_pr_id, tps, name = parse_merge_commit(commit)
          tps, name, github_pr_id = parse_squash_and_merge_commit(commit) unless github_pr_id

          next unless tps

          tps.split(',').map do |tp|
            "#{target_process_entity_link(tp, name)} (#{github_pull_request_link(github_pr_id)})"
          end
        end.join("\n")
      rescue StandardError => e
        warning 'Slackistrano: Error finding stories:'
        warning e.message
        warning e.backtrace.join("\n")
        'Error finding stories'
      end

      def story_commits
        commits.select{ |c| c[/\[(#\d+)(?:[\s,]*(#\d+))*\]/] }
      end

      def merge_commits
        commits.select{ |c| c[/^Merge pull request #(\d+).+/] }
      end

      def commits
        `git log --pretty=format:'%s %b' #{previous_revision}..#{current_revision}`.split("\n")
      end

      def parse_merge_commit(commit)
        res = commit.match(/Merge pull request #(\d+) from \S+ (?:\[(#?\w+)\])*\s?(.+)/)
        res.captures if res
      end

      def parse_squash_and_merge_commit(commit)
        res = commit.match(/\[([#\d,\s]*)\]\s*(.+)\(#(\d+)\)/)
        res.captures if res
      end

      def target_process_entity_link(entity_id, name)
        "<https://apoexab.tpondemand.com/entity/#{entity_id.gsub('#','')}|#{entity_id} - #{name}>"
      end

      def github_pull_request_link(github_pr_id)
        "<https://github.com/#{github_repo}/pull/#{github_pr_id}|Github :octocat:>" if github_pr_id
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
