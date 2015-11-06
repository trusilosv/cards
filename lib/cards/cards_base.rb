module Cards
  module CardsBase
    extend ActiveSupport::Concern

    module ClassMethods
      def retrieve_connection
        establish_connection :"cards_#{Rails.env}" unless connection_handler.connected?(self)
        super
      end
    end
  end
end
