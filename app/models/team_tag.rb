class TeamTag < ApplicationRecord
  belongs_to :team
  belongs_to :team_role, optional: true
  # NOTE: Don't add the next lines, that will pull items from multiple years which you DO NOT WANT
  # has_many :item_tags
  # has_many :items, through: :item_tags
end
