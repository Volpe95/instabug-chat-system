class Worker
    include Sneakers::Worker
  
    from_queue 'chatsystem.worker', env: nil
  
    def work(payload)
      ActiveRecord::Base.connection_pool.with_connection do
        # The message has `action` attribute that specifies the type of the crud operation to be executed.
        # convert the message into json object
  
        payload_json = JSON.parse(payload)
        # Extract the action and the chat object out of the message payload.
        action = payload_json['action']
  
        case action
        when 'create.chat'
          # create a new chat record
          chat_json = payload_json['chat']
          Chat.create!(chat_json)
        when 'update.chat'
        # update the existing chat
        # not implmented (No need for it as there is nothing can be updated)
        when 'destroy.chat'
          chat_json = payload_json['chat']
          # removes the current record of chat and the related messages to it.
          Chat.where(application_token: chat_json['token'], chat_number: chat_json['chat_number']).destroy_all

        when 'create.message'
            # create a new message record
            message_json = payload_json['message']
            message = Message.new(message_json)
            message.save!
        when 'update.message'
            # update the existing message
            message_json = payload_json['message']
            Message.where(message_json.except('message_body')).update({message_body: message_json['message_body']})
        when 'destroy.message'
            message_json = payload_json['message']
            # removes the current record of message.
            Message.where(application_token: message_json['application_token'], chat_number: message_json['chat_number'],
                            message_number: message_json['message_number']).destroy_all
        end

      end
      ack! # we need to let queue know that message was received
    end
  end
  