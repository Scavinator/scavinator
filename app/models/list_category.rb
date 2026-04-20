class ListCategory < ApplicationRecord
  belongs_to :team, optional: true

  def to_param
    self.slug
  end
end
