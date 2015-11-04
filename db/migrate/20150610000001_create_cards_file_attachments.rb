class CreateCardsFileAttachments < ActiveRecord::Migration
  def change
    create_table "cards_file_attachments", :force => true do |t|
      t.integer  :author_id
      t.string   :file_file_name
      t.string   :file_content_type
      t.integer  :file_file_size
      t.datetime :file_updated_at
      t.integer  :project_id,        :null => false
      t.integer  :card_id

      t.timestamps
    end

    add_index "cards_file_attachments", ["author_id"], :name => "cards_file_attachments_author_id_fk"
    add_index "cards_file_attachments", ["project_id"], :name => "cards_file_attachments_project_id"
  end
end
