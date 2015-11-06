module Cards
  module CardsBase
    extend ActiveSupport::Concern

    included do
      establish_connection :"cards_#{Rails.env}"
    end
  end
end
