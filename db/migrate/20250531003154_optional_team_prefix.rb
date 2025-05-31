class OptionalTeamPrefix < ActiveRecord::Migration[8.0]
  def change
    change_column_null :teams, :prefix, true
    change_column_null :team_scav_hunts, :scav_hunt_id, true
  end
end
