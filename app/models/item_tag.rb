class ItemTag < ApplicationRecord
  belongs_to :item
  belongs_to :team_tag
end
