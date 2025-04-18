class TeamScavHunt < ApplicationRecord
  belongs_to :scav_hunt
  belongs_to :team
  has_many :team_role_members
  has_many :items
  has_many :page_captains

  def to_param
    # TODO: Delete this....
    self.scav_hunt.slug
  end
end
