class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.string :application_token
      t.integer :chat_number
      t.integer :message_number
      t.text :message_body
      t.references :chat, null: false, foreign_key: true

      t.timestamps
    end
  end
end
