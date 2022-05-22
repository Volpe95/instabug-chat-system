Rails.application.routes.draw do
  namespace :api, defaults: {format: :json}  do
    namespace :v1 do

      resources :applications, param: :token do
        member do
          resources :chats, param: :chat_number do
            member do
              resources :messages, param: :message_number
            end
          end
        end
      end
    end
  end
end
