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
  has_many :item_integrations

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

  def points_value_pretty
    return nil if self.points_value.nil?
    self.points_value % 1 == 0 ? self.points_value.to_i : self.points_value
  end

  around_create :list_section_unique_validation

  def list_section_unique_validation
    self.list_category # Kick the cache so that it can show up in the error message. If the item creation transaction fails, we can't run additional queries in it.
    yield
  rescue ActiveRecord::RecordNotUnique => e
    if e.message.split("\n").first == %{PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "team_scav_hunt_list_category_item_number_unique"}
      errors.add(:list_section, "#{self.list_section_pretty} already exists")
      raise ActiveRecord::RecordInvalid, self
    else
      raise
    end
  end

  def list_section_pretty
    list_category_name = self.class.current_transaction.open? && !self.association_cached?(:list_category) ? "LC##{self.list_category_id}" : self.list_category&.name
    [list_category_name, self.page_number && "Page #{self.page_number}", "Item #{self.number}"].reject(&:nil?).join(", ")
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
