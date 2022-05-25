namespace :update_counts do
  desc 'Fetch messages count from redis and updates the `messages_count` coloumn inside the Chats table'
  task messages: :environment do
    #FixME -> Too naiive implementation, should ttake the values from Redis as batches and update them in the mysql db by batch 
    $redis.scan_each(match: 'messages_count*') do |key|
      tmp = key.split('$').last.split(':')
      token = tmp.first
      chat_number = tmp.last.to_i 
      messages_count = $redis.get(key)
      Chat.where(application_token: token, chat_number: chat_number).update(messages_count: messages_count)
    end

  end

  desc 'Fetch chats count from redis and updates the `chats_count` coloumn inside the Application table'
  task chats: :environment do
    #FixME -> Too naiive implementation, should ttake the values from Redis as batches and update them in the mysql db by batch 
    $redis.scan_each(match: 'chats_count*') do |key|
      token = key.split('$').last
      chats_count = $redis.get(key)
      Application.where(token: token).update(chats_count: chats_count)
    end

  end
end
