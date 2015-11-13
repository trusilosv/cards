module Cards
  module Files
    def self.draft_attachments_for_user(project_id, author_id)
      items = Models::FileAttachment.where(author_id: author_id, card_id: nil, project_id: project_id)
      collection_to_open_structs(items)
    end

    def self.bulk_create(params)
      return false unless params[:attachments]
      items = params[:attachments].map do |new_file|
        current_attachments(params.slice(:card_id, :project_id).reverse_merge(card_id: nil)).detect do |file|
          return false if file.file_file_name == new_file.original_filename.gsub(/\s/, '_')
        end
        new_attachment = Models::FileAttachment.new(file: new_file, author_id: params[:author_id], project_id: params[:project_id])
        unless params[:draft]
          new_attachment.card_id = params[:card_id]
        end
        new_attachment.save
        new_attachment.valid? ? new_attachment : (return false)
      end
      collection_to_open_structs(items)
    end

    def self.find_attachments(card_id)
      items = Models::FileAttachment.joins(:card)
        .where(cards_cards: { id: card_id })
        .where("cards_file_attachments.id = ANY(STRING_TO_ARRAY(cards_cards.attachments_cache, ',')::int[])")
      collection_to_open_structs(items)
    end

    def self.current_attachments(conditions)
      Models::FileAttachment.where(conditions)
    end

    def self.destroy_attachment(id)
      Models::FileAttachment.destroy(current_attachments(id: id))
    end

    private

    def self.collection_to_open_structs(items)
      items.map do |item|
        OpenStruct.new(
          file_url: item.file.url,
          thumb_url: item.file.url(:mini),
          file_name: item.file_file_name,
          extension: item.extension,
          is_image: item.image?,
          updated_at: item.updated_at,
          content_type: item.file_content_type,
          file_size: item.file.size,
          author_id: item.author_id,
          id: item.id
        )
      end
    end
  end
end
