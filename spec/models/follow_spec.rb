require 'rails_helper'

RSpec.describe Follow, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:follower) }
    it { is_expected.to belong_to(:followed) }
  end

  describe 'validations' do
    let(:alice) { create(:user) }
    let(:bob)   { create(:user) }

    it 'is valid with different follower and followed' do
      follow = build(:follow, follower: alice, followed: bob)
      expect(follow).to be_valid
    end

    it 'is invalid when following yourself' do
      follow = build(:follow, follower: alice, followed: alice)
      expect(follow).not_to be_valid
      expect(follow.errors[:base]).to be_present
    end

    it 'is invalid when duplicate follow exists' do
      create(:follow, follower: alice, followed: bob)
      dup = build(:follow, follower: alice, followed: bob)
      expect(dup).not_to be_valid
    end
  end
end
