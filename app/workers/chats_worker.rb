class ChatsWorker
    include Sneakers::Worker

    from_queue "chatsystem.chat", env: nil
  
    def work(payload)
        #The message has `action` attribute that specifies the type of the crud operation to be executed. 
      ActiveRecord::Base.connection_pool.with_connection do
        #convert the message into json object 
        payload_json = JSON.parse(payload)
        #Extract the action and the chat object out of the message payload.
        action = payload_json["action"]
        chat_json = payload_json.except("action")

        case action 
        when 'create'
            #create a new chat record 
            chat = Chat.new(chat_json)
            chat.save!
        when 'update'
            #update the existing chat 
            #not implmented
        when 'destroy'
            #removes the current record of chat and the related messages to it. 
            Chat.destroy(:application_token: chat_json['token'], :chat_number: chat_json['chat_number'])
        end
      end
      ack! # we need to let queue know that message was received
    end
end
  