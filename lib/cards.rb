require 'active_record'
require 'protected_attributes'
require 'paperclip'
# require 'cards/engine'
require 'cards/attachments'
require 'squeel'

Paperclip::Attachment.default_options.merge!(
  :path => ":rails_root/public/system/:attachment/:id/:style/:basename.:extension",
  :url => "/system/:attachment/:id/:style/:basename.:extension"
)

module Cards
  mattr_accessor :common_tags

  autoload :CardsBase, 'cards/cards_base'
  autoload :Card, 'cards/card'
  autoload :CardVersion, 'cards/card_version'
  autoload :FileAttachment, 'cards/file_attachment'
  autoload :Tag, 'cards/tag'
  autoload :Tagging, 'cards/tagging'

  def self.common_tags
    []
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
    OpenStruct.new(result.attributes) if result
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
    item = Card.create(attrs)
    OpenStruct.new(item.attributes)
  end

  def self.update_card(card_id, attrs)
    item = Card.find(card_id).update_card(attrs)
    OpenStruct.new(item.attributes)
  end

  def self.destroy_card(card_id)
    Card.find(card_id).destroy_card
    nil
  end

  def self.rollback_card(card_id)
    Card.find(card_id).destroy
    nil
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
