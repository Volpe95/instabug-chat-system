class MessagesController < ApplicationController
    before_action :set_message, only: [:show]
  
    # GET /applications/:token/chats/:chat_number/messages
    def index
        #FixME: should use pagination in here. 
        #FixME: only allow certain params. 
        @messages = Message.find_by!(application_token: params[:token], chat_number: params[:chat_number])
        json_response(@messages)
    end
  
    # GET /applications/:token/chats/:chat_number/messages/:message_number
    def show
      json_response(@message.permit(:message_body))
    end
  
    # POST /applications/:token/chats/:chat_number/message
    def create
      #Validate the provided params, then through the create request into the queue 
      
      @message = Message.new({application_token: params[:token], chat_number: params[:chat_number],
                                         message_body: params[:message_body], message_number: 0}) #Message number is zero temporary to be used in validation for now only.
      
      if !@message.valid?
        raise ActiveRecord::RecordInvalid.new(@message)
      end

      @message.message_number = get_new_message_number(params[:token], params[:chat_number])

      increment_messages_count(params[:token], params[:chat_number])
      Publisher.publish('message', {'message': @message.to_json(), 'acton': 'create'})
      json_response({message_number: @message.message_number}, :created)
    end
  
    # PUT /applications/:token/chats/:chat_number/messages/:message_number
    def update
      #TODO -> Add to the task queue as well 
      @message.update(message_params)
      Publisher.publish('message', {'message_params': message_params, 'acton': 'update'})
      head :no_content
    end
  
    # DELETE /todos/:todo_id/items/:id
    def destroy
      #TODO -> Add to the task queue as well 
      @message.destroy
      decrement_messages_count(params[:token], params[:chat_number])  
      head :no_content
    end
  
    #GET /applications/:token/chats/:chat_number/messages/search
    def search
      unless params[:query].blank?
        @results = Message.search( params[:query] )
      end
    end
  
    private
  
    def message_params
      params.permit(:message_body)
    end
  
  
    def set_message
      #FixME -> Find a way to return the params you need only. 
      @message = Message.find_by!(application__token: params[:token], chat_number: params[:chat_number], message_number: params[:message_number])
    end

    def get_new_message_number(application_token, chat_number)
        #function that gets the new chat number (only increments the current number in redis memory and returns it)
        $redis.incr("message_number_counter$#{application_token + ":" + chat_number.to_s}")
    end

    def increment_messages_count(application_token, chat_number)
        #increment the current number of chats in a specific application 
        $redis.incr("messages_count$#{application_token + ":" + chat_number.to_s}")
    end

    def decrement_messages_count(application_token, chat_number)
        #decrements the current number of chats in a specific application 
        $redis.decr("messages_count$#{application_token + ":" + chat_number.to_s}")
    end
    
  end
