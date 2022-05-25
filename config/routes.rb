Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :applications, param: :token do
        member do
          resources :chats, param: :chat_number do
            member do
              match "/messages/search", :to => "messages#search", :via => :get
              resources :messages, param: :message_number

              # resources :messages do
              #   get 'search', :on => :collection
              # end
  
            end
          end
        end
      end
    end
  end
end
