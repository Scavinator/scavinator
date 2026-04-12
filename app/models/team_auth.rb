class TeamAuth < ApplicationRecord
  belongs_to :team
  belongs_to :creator, foreign_key: :creator_id, class_name: 'User'
end
