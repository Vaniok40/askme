require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:posts).dependent(:destroy) }
    it { is_expected.to have_many(:likes).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:follows_as_follower).dependent(:destroy) }
    it { is_expected.to have_many(:follows_as_followed).dependent(:destroy) }
    it { is_expected.to have_many(:following) }
    it { is_expected.to have_many(:followers) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }

    it 'is invalid with a bad email' do
      user = build(:user, email: 'notanemail')
      expect(user).not_to be_valid
    end

    it 'is invalid with spaces in username' do
      user = build(:user, username: 'bad name')
      expect(user).not_to be_valid
    end

    it 'downcases username before validation' do
      user = create(:user, username: 'AliceTest')
      expect(user.username).to eq('alicetest')
    end
  end

  describe '#following?' do
    let(:alice) { create(:user) }
    let(:bob)   { create(:user) }

    it 'returns false when not following' do
      expect(alice.following?(bob)).to be false
    end

    it 'returns true after following' do
      alice.following << bob
      expect(alice.following?(bob)).to be true
    end
  end

  describe '.authenticate' do
    let!(:user) { create(:user, password: 'secret', password_confirmation: 'secret') }

    it 'returns the user with correct credentials' do
      expect(User.authenticate(user.email, 'secret')).to eq(user)
    end

    it 'returns nil with wrong password' do
      expect(User.authenticate(user.email, 'wrong')).to be_nil
    end

    it 'returns nil with unknown email' do
      expect(User.authenticate('nobody@example.com', 'secret')).to be_nil
    end
  end
end
