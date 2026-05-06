class ItemIntegration < ApplicationRecord
  belongs_to :item

  self.inheritance_column = nil
end
