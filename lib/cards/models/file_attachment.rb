module Cards
  module Models
    class FileAttachment < CardsBase
      include Paperclip::Glue

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

      def destroy
        if self.card_id
          updated_ids = attachments_ids - [id]
          card.update_attribute :attachments_cache, updated_ids.sort.join(",")
        else
          super # delete fiile from db if new story page
        end
      end

      def extension
        (self.file_file_name.match(/\.(\w+)$/)[1] ).downcase rescue ""
      end

      def title
        self.file_file_name
      end

      def updated_attachments_cache_ids
        updated_ids = attachments_ids << id
        card.update_attribute :attachments_cache, updated_ids.uniq.sort.join(",")
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

      def card
        @_card ||= Card.find_by_id(self.card_id)
      end

      def attachments_ids
        FileAttachment.where(id: attachments_cache_ids).map(&:id)
      end

      def current_attached_images
        attachable.attachments.where(["id IN (?) AND file_content_type LIKE 'image/%'", attachments_cache_ids])
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
end
