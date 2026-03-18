class Tag < ApplicationRecord
  TAG_REGEX = /#[[:word:]]+/.freeze

  has_many :tag_questions, dependent: :destroy
  has_many :questions, through: :tag_questions
  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags
  has_many :user_interests, dependent: :destroy

  scope :with_questions, -> { joins(:questions).distinct }

  before_validation { name&.downcase! }

  validates :name,  presence: true

  def to_param
    name
  end
end

