class ChatsWorker
  include Sneakers::Worker

  from_queue 'chatsystem.chat', env: nil

  def work(payload)
    ActiveRecord::Base.connection_pool.with_connection do
      # The message has `action` attribute that specifies the type of the crud operation to be executed.
      # convert the message into json object

      payload_json = JSON.parse(payload)
      # Extract the action and the chat object out of the message payload.
      action = payload_json['action']
      chat_json = payload_json['chat']

      case action
      when 'create'
        # create a new chat record
        Chat.create!(chat_json)
      when 'update'
      # update the existing chat
      # not implmented (No need for it as there is nothing can be updated)
      when 'destroy'
        # removes the current record of chat and the related messages to it.
        Chat.where(application_token: chat_json['token'], chat_number: chat_json['chat_number']).destroy_all
      end
    end
    ack! # we need to let queue know that message was received
  end
end
