module Cards
  class FileAttachment < CardsBase
    attr_protected

    belongs_to :card, touch: true

    has_attached_file :file, styles:  { mini:  "75x75", thumb:  "400x300>" }, whiny:  false

    # FIXME: Revert it if needed.
    # validates :file, attachment_presence: true

    do_not_validate_attachment_file_type :file

    after_create :updated_attachments_cache_ids, unless: :draft?

    before_post_process :image?

    scope :images, lambda {
      { conditions:  "file_content_type like 'image/%'" }
    }

    def self.bulk_create(parent, attachments, author, draft=false, project)
      return false unless attachments
      attachments.collect! do |new_attachment|
        parent_card = draft ? nil : Cards.find_card(parent.card_id)
        current_attachments(parent.card_id).detect do |file|
          return false if file.file_file_name == new_attachment.original_filename.gsub(/\s/, '_')
        end
        if draft
          new_attachment = Cards::FileAttachment.create(file: new_attachment, author: author, project: project)
        else
          new_attachment = parent_card.attachments.create(file: new_attachment, author: author, project: project)
        end
        new_attachment.valid? ? new_attachment : (return false)
      end
      attachments
    end

    def destroy
      if draft?
        super # delete fiile from db if new story page
      else
        updated_ids = attachable.attachments_cache_ids - [id.to_s]
        attachable.update_attribute :attachments_cache, updated_ids.sort.join(",")
      end
    end

    def extension
      (self.file_file_name.match(/\.(\w+)$/)[1] ).downcase rescue ""
    end

    def title
      self.file_file_name
    end

    def updated_attachments_cache_ids
      updated_ids = attachable.attachments_cache_ids << id.to_s
      attachable.update_attribute :attachments_cache, updated_ids.sort.join(",")
    end

    def attached?
      attachable.attachments_cache.include? self.id.to_s
    end

    def image?
      !(file_content_type =~ /^image\/.*/).nil? && (file_content_type =~ /photoshop/).nil?
    end

    def draft?
      self.card_id.nil?
    end

    private

    def attachable
      @_attachable ||= Cards::Card.find(self.card_id)
    end

    def current_attached_images
      attachable.attachments.where(["id IN (?) AND file_content_type LIKE 'image/%'", attachments_cache_ids])
    end

    def self.current_attachments(card_id)
      Cards.find_attachments(card_id)
    end
    def attachments_cache_ids
      attachable.attachments_cache ? attachable.attachments_cache.split(",").uniq : []
    end

    def self.destroy_attachment(attachment)
      return if attachment.nil?
      attachment.destroy
      attachment
    end

    def self.restore_attachment(attachment)
      return if attachment.nil?
      attachment.updated_attachments_cache_ids
      attachment
    end
  end
end
