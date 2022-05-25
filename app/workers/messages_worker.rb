class MessagesWorker
  include Sneakers::Worker

  from_queue 'chatsystem.message', env: nil

  def work(payload)
    ActiveRecord::Base.connection_pool.with_connection do
      # convert the message into json object
      puts "START"
      puts payload
      payload_json = JSON.parse(payload)
      # Extract the `action` and the `message` object out of the message payload.
      action = payload_json['action']
      message_json = payload_json['message']

      case action
      when 'create'
        # create a new message record
        message = Message.new(message_json)
        message.save!
      when 'update'
        # update the existing message
        Message.where(message_json.except('message_body')).update({message_body: message_json['message_body']})
      when 'destroy'
        # removes the current record of message.
        Message.where(application_token: message_json['application_token'], chat_number: message_json['chat_number'],
                        message_number: message_json['message_number']).destroy_all
      end
    end
    ack! # we need to let queue know that message was received
  end
end
