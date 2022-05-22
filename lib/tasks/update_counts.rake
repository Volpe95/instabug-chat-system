namespace :update_counts do
  desc "Fetch messages count from redis and updates the `messages_count` coloumn inside the Chats table"
  task messages: :environment do
    puts "Updated messages"
  end

  desc "Fetch chats count from redis and updates the `chats_count` coloumn inside the Application table"
  task chats: :environment do
    puts "Updated chats"
  end

end
