FactoryBot.define do
  factory :message do
    message_number { Faker::Number.between(from: 1, to: 100) }
    message_body { Faker::Number.within(range: 1..1000) }
    chat_id nil
  end
end
