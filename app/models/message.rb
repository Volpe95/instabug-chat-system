class Message < ApplicationRecord
  belongs_to :chat

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name 'chatsystem_message'
  document_type 'message'

  # Number of shards is set to low value for now to avoid large memory consumption  
  settings index: { number_of_shards: 1 } do
    mapping dynamic: false do
      indexes :message_body, analyzer: 'standard'
    end
  end

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          query_string: {
            query: '*' + query + '*',
            fields: ['message_body']
          }
        },
      }
    )
  end

  def as_indexed_json(_options = nil)
    as_json(only: [:message_body])
  end
end
