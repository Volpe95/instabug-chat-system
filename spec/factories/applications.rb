FactoryBot.define do
    factory :application do
      token { Faker::Lorem.characters }
      name { Faker::Lorem.word }
      chats_count { Faker::Number.within(range: 1..1000) }
    end
  end
  