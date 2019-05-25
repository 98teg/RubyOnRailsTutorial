class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  field :name, type: String
  field :email, type: String
  field :password_digest, type: String
  field :remember_digest, type: String
  field :admin,	type: Boolean, default: false
  field :activated, type: Boolean, default: false
  field :activation_digest, type: String
  field :activated_at, type: Time
  field :reset_digest, type: String
  field :reset_sent_at, type: Time

  embeds_many :microposts
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy,
                                  inverse_of: :follower
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy,
                                  inverse_of: :followed

  attr_accessor :remember_token, :activation_token, :reset_token

  before_save   :downcase_email
  before_create :create_activation_digest
  before_destroy:delete_microposts

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
					format: { with: VALID_EMAIL_REGEX },
					uniqueness: {case_sensitive: false }

  index({ email: 1 })

  has_secure_password

  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
												  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def toggle!
    value = ! self.activated?
    update_attribute(:activated, value)
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def feed
    self.microposts
  end

  def follow(other_user)
    active_relationships.create(follower_id: self.id, followed_id: other_user.id)
  end

  def unfollow(other_user)
    active_relationships.find_by(follower_id: self.id, followed_id: other_user.id).destroy
  end

  def following?(other_user)
    not active_relationships.where(follower_id: self.id, followed_id: other_user.id).blank?
  end

  def followed_by?(other_user)
    not passive_relationships.where(follower_id: other_user.id, followed_id: self.id).blank?
  end

  private

    def downcase_email
      self.email = email.downcase
    end

    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

    def delete_microposts
		while self.microposts.count != 0
			self.microposts.first.destroy
		end
    end
end
