require 'openssl'

class User < ApplicationRecord
  ITERATIONS = 20_000
  DIGEST = OpenSSL::Digest.new('SHA256')
  EMAIL_VALID_MASK = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  USERNAME_VALID_MASK = /\A\w+\z/

  attr_accessor :password

  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :interests, class_name: 'UserInterest', dependent: :destroy
  has_many :followed_tags, through: :interests, source: :tag
  has_many :sent_conversations,     class_name: 'Conversation', foreign_key: :sender_id,    dependent: :destroy
  has_many :received_conversations, class_name: 'Conversation', foreign_key: :recipient_id, dependent: :destroy
  has_many :notifications, dependent: :destroy

  has_many :follows_as_follower, class_name: 'Follow', foreign_key: :follower_id, dependent: :destroy
  has_many :follows_as_followed, class_name: 'Follow', foreign_key: :followed_id, dependent: :destroy
  has_many :following, through: :follows_as_follower, source: :followed
  has_many :followers, through: :follows_as_followed, source: :follower

  def following?(user)
    following.exists?(user.id)
  end

  before_validation :username_to_downcase
  before_save :encrypt_password

  validates :username,
            presence: true,
            length: { maximum: 40 },
            format: { with: USERNAME_VALID_MASK }

  validates :email,
            presence: true,
            uniqueness: true,
            format: { with: EMAIL_VALID_MASK }

  validates :password,
            presence: true,
            confirmation: true,
            on: :create

  def self.authenticate(email, password)
    user = find_by(email:)

    return nil unless user.present?

    hashed_password = User.hash_to_string(
      OpenSSL::PKCS5.pbkdf2_hmac(
        password, user.password_salt, ITERATIONS, DIGEST.length, DIGEST
      )
    )

    return user if user.password_hash == hashed_password

    nil
  end

  def self.hash_to_string(password_hash)
    password_hash.unpack1('H*')
  end

  private

  def encrypt_password
    return unless password.present?

    self.password_salt = User.hash_to_string(OpenSSL::Random.random_bytes(16))
    self.password_hash = User.hash_to_string(
      OpenSSL::PKCS5.pbkdf2_hmac(
        password, password_salt, ITERATIONS, DIGEST.length, DIGEST
      )
    )
  end

  def username_to_downcase
    username&.downcase!
  end
end
