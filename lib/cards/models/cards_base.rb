module Cards
  module Models
    class CardsBase < ActiveRecord::Base
      establish_connection Cards.database

      self.abstract_class = true
    end
  end
end
