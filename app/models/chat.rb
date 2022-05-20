class Chat < ApplicationRecord
  # associations 
  belongs_to :application
  has_many :messages, dependent: :destroy

  # validations
  validates_presence_of :chat_number, :messages_count
end
