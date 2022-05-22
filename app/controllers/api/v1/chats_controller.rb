class Api::V1::ChatsController < ApplicationController

  before_action :set_chat, only: [:show]
  
  # GET /api/v1/applications/:token/chats
  def index
      #FixME: should use pagination in here. 
      #FixME: only allow certain params. 
      chats = Chat.where(application_token: params[:token])
      json_response(chats)
  end

  # GET /applications/:token/chats/:chat_number
  def show
    json_response(@chat.permit(:chat_number))
  end

  # POST /applications/:token/chats
  def create
    #Validate the provided params, then through the create request into the queue 
    
    @chat = Chat.new({application_token: params[:token], chat_number: 0, messages_count: 0}) #Chat number is zero to be used in validation for now only.
    
    if !@chat.valid?
      raise ActiveRecord::RecordInvalid.new(@chat)
    end

    @chat.chat_number = get_new_chat_number params[:token]
    increment_chats_count params[:token]      
    Publisher.publish('chat', {'chat': @chat.to_json(), 'action': 'create'})
    json_response({chat_number: @chat.chat_number}, :created)
  end

  # PUT /applications/:token/chats/:chat_number
  def update
    #Why would we need the user to modify the chat? user can't modify chat number or the messages counts directly
    #@chat.update(chat_params)
    head :no_content
  end

  # DELETE /applications/:token/chats/:chat_number
  def destroy
    #TODO -> Add to the task queue as well 
    Publisher.publish('chat', {'chat': {'token': params[:token], 'chat_number': params[:chat_number]}, 'action': 'destroy'})
    decrement_chats_count params[:token]      
    head :no_content
  end

  private

  def chat_params
    params.permit(:chat_number, :messages_count)
  end


  def set_chat
    @chat = Chat.find_by!(application_token: params[:token], chat_number: params[:chat_number])
  end

  def get_new_chat_number(application_token)
      #function that gets the new chat number (only increments the current number in redis memory and returns it)
      $redis.incr("chat_number_counter$#{application_token}")
  end

  def increment_chats_count(application_token)
      #increment the current number of chats in a specific application 
      $redis.incr("chats_count$#{application_token}")
  end

  def decrement_chats_count(application_token)
      #decrements the current number of chats in a specific application 
      $redis.decr("chats_count$#{application_token}")
  end
  

end
