class CreateCardsCards < ActiveRecord::Migration
  def change
    create_table :cards_cards do |t|
      t.string  :name
      t.text    :description
      t.integer :version
      t.integer :author_id
      t.integer :project_id
      t.text    :attachments_cache
      t.integer :parent_id
      t.boolean :mark_as_deleted,   :default => false

      t.timestamps
    end

    add_index "cards_cards", ["parent_id"], :name => "cards_cards_on_parent_id_ix"
  end
end
