class CreateCardsCardVersions < ActiveRecord::Migration
  def change
    create_table :cards_card_versions do |t|
      t.string  :name
      t.text    :description
      t.integer :author_id
      t.integer :version
      t.integer :card_id
      t.text    :attachments_cache

      t.timestamps
    end
  end
end
