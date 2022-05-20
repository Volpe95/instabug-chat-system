require 'rails_helper'

# Test suite for the Chat model
RSpec.describe Message, type: :model do
  # Association test
  it { should belong_to(:chat) }
  # Validation test
  it { should validate_presence_of(:message_number) }
  it { should validate_presence_of(:message_body) }
end
