class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :title, presence: true, length: { maximum: 150 }
  validates :body, presence: true

  after_save :extract_tags

  scope :sorted_desc, -> { order(created_at: :desc) }
  scope :for_interests, lambda { |tag_ids|
    joins(:post_tags).where(post_tags: { tag_id: tag_ids }).distinct.order(created_at: :desc)
  }

  def liked_by?(user)
    return false unless user

    likes.exists?(user:)
  end

  private

  def extract_tags
    names = (title + ' ' + body).scan(Tag::TAG_REGEX).map { |t| t.delete('#').downcase }.uniq
    names.each do |name|
      tag = Tag.find_or_create_by(name:)
      PostTag.find_or_create_by(post: self, tag:)
    end
  end
end
