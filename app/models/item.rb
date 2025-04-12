class Item < ApplicationRecord
  belongs_to :team_scav_hunt
  has_many :item_tags
  has_many :team_tags, through: :item_tags
  has_many :item_users
  has_many :users, through: :item_users
end
