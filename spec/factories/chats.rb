FactoryBot.define do
  factory :chat do
    chat_number { Faker::Number.between(from: 1, to: 100) }
    messages_count { Faker::Number.within(range: 1..1000) }
    application_id nil
  end
end
