class CreateCardsTagsAndTaggings < ActiveRecord::Migration
  def change
    create_table "cards_tags", :force => true do |t|
      t.string  "name"
      t.integer "project_id",                         :null => false
      t.boolean "mark_as_deleted", :default => false
    end

    add_index "cards_tags", ["name"], :name => "index_cards_tags_on_name"
    add_index "cards_tags", ["project_id"], :name => "cards_tags_project_id_fk"

    create_table "cards_taggings", :force => true do |t|
      t.integer  "tag_id",     :null => false
      t.integer  "card_id",   :null => false
      t.datetime "created_at"
      t.integer  "project_id", :null => false
    end

    add_index "cards_taggings", ["project_id"], :name => "index_cards_taggings_on_project_id"
    add_index "cards_taggings", ["card_id"], :name => "index_cards_taggings_on_taggable_id_and_taggable_type"
    add_index "cards_taggings", ["tag_id", "card_id"], :name => "index_cards_taggings_on_tag_id_and_card_id", :unique => true
    add_index "cards_taggings", ["tag_id"], :name => "index_cards_taggings_on_tag_id"
  end
end
