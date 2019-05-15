class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :email, type: String

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 }
end
