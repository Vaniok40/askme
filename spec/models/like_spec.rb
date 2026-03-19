require 'rails_helper'

RSpec.describe Like, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:post) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    let(:post) { create(:post) }
    let(:user) { create(:user) }

    it 'is invalid if same user likes same post twice' do
      create(:like, post: post, user: user)
      dup = build(:like, post: post, user: user)
      expect(dup).not_to be_valid
    end
  end

  describe 'notifications' do
    let(:author) { create(:user) }
    let(:liker)  { create(:user) }
    let(:post)   { create(:post, user: author) }

    it 'creates a notification for the post owner on like' do
      expect { create(:like, post: post, user: liker) }
        .to change { Notification.count }.by(1)
    end

    it 'does not create a notification when author likes own post' do
      expect { create(:like, post: post, user: author) }
        .not_to change { Notification.count }
    end

    it 'removes the notification when like is destroyed' do
      like = create(:like, post: post, user: liker)
      expect { like.destroy }.to change { Notification.count }.by(-1)
    end
  end
end
