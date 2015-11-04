module Cards
  class Tagging < ::ActiveRecord::Base
    include CardsBase

    belongs_to :tag
    belongs_to :card, inverse_of: :taggings

    attr_accessible :tag, :card, :card_id, :tag_id

    before_validation :set_project_id

    validates :tag, presence:  true
    validates :card, presence:  true
    validates :tag_id, uniqueness: { scope: :card_id }

    private

    def set_project_id
      self.project_id = tag.project_id
    end
  end
end
