module Cards
  class Card < ActiveRecord::Base
    include CardsBase

    attr_accessible :description, :name, :version, :tag_list, :project_id, :author_id, :parent_id, :mark_as_deleted
    has_versioning only: ['name', 'description'], time_interval: 20.seconds
    has_many :taggings, inverse_of: :card
    has_many :tags, -> { uniq }, through: :taggings, dependent: :destroy
    belongs_to :author, class_name: Cards.author_class_name
    has_many :attachments, class_name: "Cards::FileAttachment", dependent: :destroy
    belongs_to :parent, class_name: 'Cards::Card'
    has_many :children, foreign_key: :parent_id, class_name: 'Cards::Card'

    after_save :store_tags

    def tag_list
      if attribute_changed?('tag_list')
        @tag_list
      else
        self.tags.map(&:name).sort
      end
    end

    def tag_list=(new_tags)
      attribute_will_change!('tag_list')
      @tag_list = new_tags
      @tag_list = new_tags.to_s.split(',').uniq if new_tags.is_a?(String) || new_tags.nil?
    end

    def current_attachments
      self.attachments.where(id: attachments_cache_ids)
    end

    def current_attached_images
      attachments.where(["id IN (?) AND file_content_type LIKE 'image/%'", attachments_cache_ids])
    end

    def attachments_cache_ids
      attachments_cache ? attachments_cache.split(",") : []
    end

    def update_attachments(attachment_ids)
      if attachment_ids.present?
        FileAttachment.find(attachment_ids).each do |attachment|
          attachment.card_id = id
          attachment.save
          attachment.updated_attachments_cache_ids
        end
      end
    end

    def update_card(attrs)
      self.update_attributes(attrs)
    end

    def destroy_card
      self.update_attributes(mark_as_deleted: !self.mark_as_deleted)
    end

    private

    def list_of_new_tags tags
      parsed_tags(tags) - existing_tags(tags).map(&:name)
    end

    def existing_tags tags
      Tag.where(project_id: project_id, name: parsed_tags(tags))
    end

    def parsed_tags tags
      tags.map(&:strip)
    end

    def store_tags
      unless @tag_list.nil?
        list_of_new_tags(@tag_list).each do |tag_name|
          self.tags.create(name: tag_name, project_id: project_id)
        end
        existing_tags(@tag_list).update_all(mark_as_deleted: false)
        removed_tags = self.tag_ids - existing_tags(@tag_list).map(&:id)
        self.taggings.where(tag_id: removed_tags).destroy_all
        self.tag_ids = existing_tags(@tag_list).map(&:id)
      end
    end
  end
end
