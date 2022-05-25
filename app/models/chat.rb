class Chat < ApplicationRecord
  belongs_to :application

  validates_presence_of :application_token, :chat_number, :messages_count
end
