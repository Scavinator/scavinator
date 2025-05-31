class CreateTeamIntegrations < ActiveRecord::Migration[8.0]
  def change
    create_table :team_integrations do |t|
      t.references :team, null: false, foreign_key: true
      t.jsonb :integration_data, index: {unique: true}

      t.timestamps
    end
  end
end
