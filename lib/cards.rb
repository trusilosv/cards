require 'paperclip'
require 'cards/engine'
require 'cards/attachments'

Paperclip::Attachment.default_options.merge!(
  :path => ":rails_root/public/system/:attachment/:id/:style/:basename.:extension",
  :url => "/system/:attachment/:id/:style/:basename.:extension"
)

module Cards
  mattr_accessor :author_class_name
  mattr_accessor :project_class_name
  mattr_accessor :common_tags

  def self.author_class
    @@author_class_name.constantize
  end

  def self.project_class
    @@project_class_name.constantize
  end

  #TODO: Move not-deleted tags functionality to tracker.
  def self.project_tags(project_id)
    (Tag.where(project_id: project_id).not_deleted.pluck(:name) | common_tags).sort
  end

  def self.all_tags(project_id)
    (Tag.where(project_id: project_id).pluck(:name) | common_tags).sort
  end

  def self.card_tags(card_id)
    Tag.joins(:taggings).where(taggings: { card_id: card_id } ).order(:name).pluck(:name)
  end

  def self.find_card(card_id)
    result = Card.select("cards_cards.*")
      .select("COALESCE((#{tag_scope.to_sql}), '{}') AS tag_names")
      .where(id: card_id)
      .first
    OpenStruct.new(result.attributes)
  end

  def self.find_cards(card_ids)
    items = Card.select("cards_cards.*")
      .select("COALESCE((#{tag_scope.to_sql}), '{}') AS tag_names")
      .where(id: card_ids)
    collection_to_open_structs(items)
  end

  def self.find_last_version(card_id)
    item = CardVersion.where(card_id: card_id).order("updated_at DESC").first
    OpenStruct.new(item.attributes)
  end

  def self.find_child_cards(parent_id)
    items = Card.select("cards_cards.*")
      .where(parent_id: parent_id)
      .to_a
    collection_to_open_structs(items)
  end

  def self.find_attachments(card_id)
    items = FileAttachment.joins(:card)
      .where(cards_cards: { id: card_id })
      .where("cards_file_attachments.id = ANY(STRING_TO_ARRAY(cards_cards.attachments_cache, ',')::int[])")
    collection_to_open_structs(items)
  end

  def self.create_card(attrs)
    Card.create(attrs)
  end

  def self.update_card(card_id, attrs)
    card = Card.find(card_id).update_card(attrs)
  end

  def self.destroy_card(card_id)
    Card.find(card_id).destroy_card
  end

  def self.rollback_card(card_id)
    Card.find(card_id).destroy
  end

  private

  def self.tag_scope
    Tag.joins(:taggings).where("cards_taggings.card_id = cards_cards.id").select("ARRAY_AGG(name ORDER BY name)")
  end

  def self.collection_to_open_structs(items)
    items.map do |item|
      OpenStruct.new(item.attributes)
    end
  end
end
