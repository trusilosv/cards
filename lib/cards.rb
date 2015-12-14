require 'active_record'
require 'protected_attributes'
require 'cards/attachments'
require 'squeel'

module Cards
  mattr_accessor :common_tags

  autoload :Models, 'cards/models'
  # autoload :Card, 'cards/models/card'
  # autoload :CardVersion, 'cards/models/card_version'
  # autoload :FileAttachment, 'cards/models/file_attachment'
  # autoload :Tag, 'cards/models/tag'
  # autoload :Tagging, 'cards/models/tagging'

  def self.common_tags
    @@common_tags || []
  end

  #TODO: Move not-deleted tags functionality to tracker.
  def self.project_tags(project_id)
    (Models::Tag.where(project_id: project_id).not_deleted.pluck(:name) | common_tags).sort
  end

  def self.all_tags(project_id)
    (Models::Tag.where(project_id: project_id).pluck(:name) | common_tags).sort
  end

  def self.card_tags(card_id)
    Models::Tag.joins(:taggings).where(taggings: { card_id: card_id } ).order(:name).pluck(:name)
  end

  def self.versions(card_id, versions=nil)
    items = Models::CardVersion.select("card_id, version, name, description, author_id, updated_at")
      .select('lead(name, 1) OVER (order by version DESC) as previous_name')
      .select('lead(description, 1) OVER (order by version DESC) as previous_description')
      .where(card_id: card_id)
      .order('version DESC')
    if versions
      items = items.where(version: versions)
    end
    collection_to_open_structs(items)
  end

  def self.find_version(card_id, version)
    item = Models::CardVersion.select("card_id, version, name, description, author_id, updated_at")
      .where(card_id: card_id, version: version)
      .first
    OpenStruct.new(item.attributes) if item
  end

  def self.find_card(card_id)
    result = Models::Card.select("cards_cards.*")
      .select("COALESCE((#{tag_scope.to_sql}), '{}') AS tag_names")
      .where(id: card_id)
      .first
    OpenStruct.new(result.attributes) if result
  end

  def self.find_cards(card_ids)
    items = Models::Card.select("cards_cards.*")
      .select("COALESCE((#{tag_scope.to_sql}), '{}') AS tag_names")
      .where(id: card_ids)
    collection_to_open_structs(items)
  end

  def self.find_last_version(card_id)
    item = Models::CardVersion.where(card_id: card_id).order("updated_at DESC").first
    OpenStruct.new(item.attributes)
  end

  def self.find_child_cards(parent_id)
    items = Models::Card.select("cards_cards.*")
      .where(parent_id: parent_id)
      .to_a
    collection_to_open_structs(items)
  end

  def self.create_card(attrs)
    item = Models::Card.create(attrs)
    OpenStruct.new(item.attributes.merge(tag_names: item.tag_list))
  end

  def self.update_card(card_id, attrs)
    item = Models::Card.find(card_id)
    item.update_attributes(attrs)
    OpenStruct.new(item.attributes.merge(tag_names: item.tag_list))
  end

  def self.destroy_card(card_id)
    Models::Card.find(card_id).destroy_card
    nil
  end

  def self.rollback_card(card_id)
    Models::Card.find(card_id).destroy
    nil
  end

  private

  def self.tag_scope
    Models::Tag.joins(:taggings).where("cards_taggings.card_id = cards_cards.id").select("ARRAY_AGG(name ORDER BY name)")
  end

  def self.collection_to_open_structs(items)
    items.map do |item|
      OpenStruct.new(item.attributes)
    end
  end
end
