class Application < ApplicationRecord
  # model association
  has_many :chats, dependent: :destroy
  has_secure_token
  has_secure_token :token, length: 36
  # validations
  validates_presence_of :name, :chats_count
end
