class Api::V1::ChatsController < ApplicationController
  before_action :set_application, only: [:create]

  # GET /api/v1/applications/:token/chats
  def index
    # FIXME: should use pagination in here.
    # FixME: only allow certain params.
    chats = Chat.where(application_token: params[:token]).select(:application_token,
                                                                 :chat_number).to_json(except: :id)
    json_response(chats)
  end

  # GET /api/v1/applications/:token/chats/:chat_number
  def show
    chat = Chat.where(application_token: params[:token], chat_number: params[:chat_number]).select(:application_token,
                                                                                                   :chat_number).to_json(except: :id)
    json_response(chat)
  end

  # POST /api/v1/applications/:token/chats
  def create
    # Validate the provided params, then throw the create request into the queue

    raise ActiveRecord::RecordNotFound, @application if @application.nil?

    @chat = Chat.new({ application_token: params[:token], chat_number: 0, messages_count: 0 }) # Chat number is zero to be used in validation for now only.
    @chat.application = @application

    raise ActiveRecord::RecordInvalid, @chat unless @chat.valid?

    @chat.chat_number = get_new_chat_number params[:token]
    increment_chats_count params[:token]

    Publisher.publish('chat',
                      { 'chat': @chat.attributes.slice('application_token', 'chat_number', 'application_id', 'messages_count'),
                        'action': 'create' }.to_json)

    json_response({ chat_number: @chat.chat_number }, :created)
  end

  # PUT /api/v1/applications/:token/chats/:chat_number
  def update
    # Why would we need the user to modify the chat? user can't modify chat number or the messages counts directly
    head :no_content
  end

  # DELETE /api/v1/applications/:token/chats/:chat_number
  def destroy
    # TODO: -> Add to the task queue as well

    Publisher.publish('chat',
                      { 'chat': { 'token': params[:token], 'chat_number': params[:chat_number] },
                        'action': 'destroy' }.to_json)
    decrement_chats_count params[:token]
    head :no_content
  end


  private

  def set_application
    @application = Application.find_by!(token: params[:token])
  end

  def get_new_chat_number(application_token)
    # function that gets the new chat number (only increments the current number in redis memory and returns it)
    $redis.incr("chat_number_counter$#{application_token}")
  end

  def increment_chats_count(application_token)
    # increment the current number of chats in a specific application
    $redis.incr("chats_count$#{application_token}")
  end

  def decrement_chats_count(application_token)
    # decrements the current number of chats in a specific application
    $redis.decr("chats_count$#{application_token}")
  end
end
