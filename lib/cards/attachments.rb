module Cards
  def self.draft_attachments_for_user(project, author)
    Cards::FileAttachment.where(author_id: author, card_id: nil, project_id: project)
  end
end