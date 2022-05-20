require 'rails_helper'

# Test suite for the Application model
RSpec.describe Application, type: :model do
  # Association test
  it { should have_many(:chats).dependent(:destroy) }
  # Validation tests
  it { should validate_presence_of(:token) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:chats_count) }
end
