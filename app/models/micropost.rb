class Micropost
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content, type: String
  embedded_in :user, validate: true

  default_scope -> { order_by([:created_at, :desc]) }

  validates :content, presence: true, length: { maximum: 140 }
end
