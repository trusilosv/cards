module Cards
  module Models
    class CardsBase < ActiveRecord::Base
      establish_connection :"cards_#{Rails.env}"

      self.abstract_class = true
    end
  end
end
