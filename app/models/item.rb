class Item < ApplicationRecord
  belongs_to :team_scav_hunt
  has_many :item_tags
  has_many :team_tags, through: :item_tags
  has_many :item_users
  has_many :users, through: :item_users
  has_many :item_events
  has_one :item_submission
  has_many :item_files
  belongs_to :list_category, optional: true

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

  # Note: We use #length for the associations because in the case of eager loading, it
  # won't cause any additional queries. #exist? and #.count > 0 both cause additional
  # queries
  def timed
    self.item_events.length > 0
  end

  def assigned
    self.item_users.length > 0
  end

  def submitted
    !self.item_submission.nil?
  end
end
