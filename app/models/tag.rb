class Tag < ApplicationRecord
  TAG_REGEX = /#[[:word:]]+/.freeze

  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags
  has_many :user_interests, dependent: :destroy

  before_validation { name&.downcase! }

  validates :name,  presence: true

  def to_param
    name
  end
end

