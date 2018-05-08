require 'spec_helper'

describe Slackistrano::Messaging::Apoex do
  let(:merge_commit) { "Merge pull request #447 from apoex/another-branch [#9619] This is a merge commit" }
  let(:squash_merge_commit) { "* [#1337] The best feature ever (#12)\r" }
  let(:commits) do
    [
      "Commit ",
      merge_commit,
      "Squash commit (#443) * Commit\r",
      "\r",
      "* Another Commit\r",
      "\r",
      squash_merge_commit
    ]
  end

  before do
    allow(subject).to receive(:fetch).with(:repo_url).and_return('git@github.com:apoex/test.git')
    allow(subject).to receive(:commits).and_return(commits)
  end

  describe '#deployer' do
    before do
      allow(subject).to receive(:deployer_name_from_git).and_return(git_config_name)
    end

    context 'when git config missing' do
      let(:git_config_name) { '' }

      it 'calls super' do
        expect(subject.deployer).to eq(ENV['USER'])
      end
    end

    context 'when git config exists' do
      let(:git_config_name) { 'Steve Jobs' }

      it 'returns the name' do
        expect(subject.deployer).to eq('Steve Jobs')
      end
    end
  end

  describe '#merge_commits' do
    it 'returns the merge commits' do
      expect(subject.merge_commits).to eq([merge_commit])
    end
  end

  describe '#story_commits' do
    it 'returns merge commits related to a story' do
      expect(subject.story_commits).to eq([merge_commit, squash_merge_commit])
    end
  end

  describe '#pull_requests' do
    before do
      expect(subject).to receive(:merge_commits).and_return([merge_commit])
    end

    it 'returns the pull requests' do
      expect(subject.pull_requests).to eq("This is a merge commit <https://github.com/apoex/test/pull/447|Github :octocat:>")
    end
  end

  describe '#stories' do
    let(:story_commit) { squash_merge_commit }

    before do
      expect(subject).to receive(:story_commits).and_return([story_commit])
    end

    it 'returns the stories' do
      expect(subject.stories).to eq("<https://apoexab.tpondemand.com/entity/1337|#1337 - The best feature ever > (<https://github.com/apoex/test/pull/12|Github :octocat:>)")
    end

    context 'when story commit is reverted' do
      let(:story_commit) { "  Revert \"[#12345] Bad code\"" }

      it 'Ignores the story' do
        expect(subject.stories).to be_empty
      end

      context 'when merge commit' do
        let(:story_commit) { "Merge pull request #1815 from apoex/revert-1794-10934-full-package-item-count Revert \"[#10934] Default the number of picking full package items to 1\"" }

        it 'Ignores the story' do
          expect(subject.stories).to be_empty
        end
      end
    end
  end
end
