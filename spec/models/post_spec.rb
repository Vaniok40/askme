require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:post_tags).dependent(:destroy) }
    it { is_expected.to have_many(:tags).through(:post_tags) }
    it { is_expected.to have_many(:likes).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_length_of(:title).is_at_most(150) }
  end

  describe '#liked_by?' do
    let(:post) { create(:post) }
    let(:user) { create(:user) }

    it 'returns false when not liked' do
      expect(post.liked_by?(user)).to be false
    end

    it 'returns true after liking' do
      create(:like, post: post, user: user)
      expect(post.liked_by?(user)).to be true
    end

    it 'returns false for nil user' do
      expect(post.liked_by?(nil)).to be false
    end
  end

  describe 'scopes' do
    it '.sorted_desc returns posts newest first' do
      old_post = create(:post, created_at: 2.days.ago)
      new_post = create(:post, created_at: 1.hour.ago)
      expect(Post.sorted_desc.first).to eq(new_post)
      expect(Post.sorted_desc.last).to eq(old_post)
    end

    it '.for_interests returns posts matching tag ids' do
      tag = create(:tag)
      matching = create(:post)
      other    = create(:post)
      PostTag.create!(post: matching, tag: tag)

      result = Post.for_interests([tag.id])
      expect(result).to include(matching)
      expect(result).not_to include(other)
    end
  end
end
