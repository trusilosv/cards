module Cards
  module Models
    class CardVersion < CardsBase
      attr_reader
      belongs_to :card

      before_save :set_version

      private

      def set_version
        self.version = card.version
      end
    end
  end
end
