class Item < ApplicationRecord
  belongs_to :team_scav_hunt
  has_many :item_tags
  has_many :team_tags, through: :item_tags
  has_many :item_users
  has_many :users, through: :item_users
  belongs_to :list_category

  def for_url
    if category_slug = list_category&.slug
      [category_slug, number]
    else
      [nil, number]
    end
  end

  def to_param
    raise "Attempted to generate an item url. This is not possible. Use *item.url_for instead"
  end
end
