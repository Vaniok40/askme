require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:post) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_length_of(:body).is_at_most(1000) }
  end

  describe 'notifications' do
    let(:author)    { create(:user) }
    let(:commenter) { create(:user) }
    let(:post)      { create(:post, user: author) }

    it 'creates a notification for the post owner on comment' do
      expect { create(:comment, post: post, user: commenter) }
        .to change { Notification.count }.by(1)
    end

    it 'does not create a notification when author comments on own post' do
      expect { create(:comment, post: post, user: author) }
        .not_to change { Notification.count }
    end
  end
end
