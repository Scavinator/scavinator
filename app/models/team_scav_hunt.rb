class TeamScavHunt < ApplicationRecord
  belongs_to :scav_hunt
  belongs_to :team
  has_many :team_role_members
  has_many :items
  has_many :page_captains

  def to_param
    self.scav_hunt.to_param
    # This probably should be an error -- when used in the team_scav_hunt_*_path helpers it is
    # always going to be filling the ScavHunt.slug slot. However at almost every point it's more
    # convenient to work with a TeamScavHunt then a ScavHunt, that's  how I wrote it initially
    # and there's not really an advantage to switching everything over now. At the moment, doing
    # this seems like it adds convenience at no cost so it stays. However if it ever becomes
    # advantageous to make this an error, it should become one.
    #
    # raise ArgumentError "Cannot generate a URL with a TeamScavHunt"
  end
end
