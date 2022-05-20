class Message < ApplicationRecord
  belongs_to :chat

  # validations
  validates_presence_of :message_number, :message_body

end
