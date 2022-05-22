class MessagesWorker
    include Sneakers::Worker

    from_queue "chatsystem.message", env: nil
  
    def work(payload)
        #The message has `action` attribute that specifies the type of the crud operation to be executed. 
      ActiveRecord::Base.connection_pool.with_connection do
        #convert the message into json object 
        payload_json = JSON.parse(payload)
        #Extract the `action` and the `message` object out of the message payload.
        action = payload_json["action"]
        message_json = payload_json.except("action")

        case action 
        when 'create'
            #create a new message record 
            message = Message.new(message_json['message'])
            message.save!
        when 'update'
            #update the existing message
            Message.update(message_json['message_params'])
        when 'destroy'
            #removes the current record of message.
            Message.destroy(:application_token: message_json['token'], :chat_number: message_json['chat_number'], message_number: message_json['message_number'])
        end
      end
      ack! # we need to let queue know that message was received
    end
end
  