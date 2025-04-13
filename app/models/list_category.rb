class ListCategory < ApplicationRecord
  belongs_to :team, optional: true
end
