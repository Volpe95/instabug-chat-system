class Api::V1::MessagesController < ApplicationController
  before_action :set_chat, only: [:create]
  before_action :check_params, only: [:create, :update]
  
  # GET /applications/:token/chats/:chat_number/messages
  def index
    # FIXME: should use pagination in here.
    # FixME: only allow certain params.
    messages = Message.where(application_token: params[:token], chat_number: params[:chat_number])
                      .select(:message_body, :message_number)
                      .to_json(except: :id)

    json_response(messages)
  end

  # GET /applications/:token/chats/:chat_number/messages/:message_number
  def show
    message = Message.where(application_token: params[:token], chat_number: params[:chat_number], message_number: params[:message_number])
                     .select(:message_body, :message_number)
                     .to_json(except: :id)

    json_response(message)
  end

  # POST /applications/:token/chats/:chat_number/message
  def create
    # Validate the provided params, then throw the create request into the queue
    params.require(:message_body)

    raise ActiveRecord::RecordNotFound, @chat if @chat.nil?

    @message = Message.new(
    { application_token: params[:token],
      chat_number: params[:chat_number],
      message_body: params[:message_body],
      message_number: 0 }) # Message number is zero temporary to be used in validation for now only.

    @message.chat = @chat
    raise ActiveRecord::RecordInvalid, @message unless @message.valid?

    @message.message_number = get_new_message_number(params[:token], params[:chat_number])

    increment_messages_count(params[:token], params[:chat_number])

    Publisher.publish('worker',
                    {'message': @message.attributes.slice('application_token', 'chat_number', 'message_body', 'message_number', 'chat_id'),
                    'action': 'create.message'}.to_json)

    json_response({ message_number: @message.message_number }, :created)
  end

  # PUT /applications/:token/chats/:chat_number/messages/:message_number
  def update
    Publisher.publish('worker', 
                        {'action': 'update.message',
                          'message': {'application_token': params[:token],
                                      'chat_number': params[:chat_number], 
                                      'message_number': params[:message_number], 
                                      'message_body': params[:message_body]}
                                      }.to_json())
    head :no_content
  end

  # DELETE /todos/:todo_id/items/:id
  def destroy
    Publisher.publish(exchange = 'worker', 
                  message = {'action': 'destroy.message',
                                'message': {'application_token': params[:token],
                                            'chat_number': params[:chat_number], 
                                            'message_number': params[:message_number], 
                                            }}.to_json())
    decrement_messages_count(params[:token], params[:chat_number])
    head :no_content
  end

  # GET /applications/:token/chats/:chat_number/messages/search
  def search
    @results = Message.search(params[:query]) unless params[:query].blank?
    json_response(@results.map{|value| value.as_json["_source"]})
  end

  private

  def check_params
    render json: { error: "`message_body` should be provided in the request body" }, status: 400 if params[:message_body].nil?
  end

  def set_chat
    @chat = Chat.find_by(application_token: params[:token], chat_number: params[:chat_number])
  end

  def get_new_message_number(application_token, chat_number)
    # function that gets the new chat number (only increments the current number in redis memory and returns it)
    $redis.incr("message_number_counter$#{application_token + ':' + chat_number.to_s}")
  end

  def increment_messages_count(application_token, chat_number)
    # increment the current number of chats in a specific application
    $redis.incr("messages_count$#{application_token + ':' + chat_number.to_s}")
  end

  def decrement_messages_count(application_token, chat_number)
    # decrements the current number of chats in a specific application
    $redis.decr("messages_count$#{application_token + ':' + chat_number.to_s}")
  end
end
