module Cards
  class CardVersion < CardsBase
    attr_protected
    belongs_to :card

    before_save :set_version

    default_scope { order(:id) }

    # def previous
    #   CardsVersion.where("cards_id = ? AND version < ?", cards_cards.id, version).order(:version).first
    # end
    #
    # def next
    #   CardsVersion.where("cards_id = ? AND version > ?", cards_cards.id, version).order(:version).last
    # end

    private

    def set_version
      self.version = card.version
    end
  end
end
