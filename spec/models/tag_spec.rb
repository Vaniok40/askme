require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:post_tags).dependent(:destroy) }
    it { is_expected.to have_many(:posts).through(:post_tags) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  it 'downcases name before validation' do
    tag = create(:tag, name: 'Ruby')
    expect(tag.name).to eq('ruby')
  end

  it 'uses name as URL param' do
    tag = create(:tag, name: 'rails')
    expect(tag.to_param).to eq('rails')
  end
end
