class Application < ApplicationRecord
    # model association
    has_many :chats, dependent: :destroy
  
    # validations
    validates_presence_of :token, :name, :chats_count
  end
  