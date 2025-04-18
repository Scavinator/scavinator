class TeamScavHuntSlugToScavHunt < ActiveRecord::Migration[8.0]
  def change
    remove_index :team_scav_hunts, column: [:team_id, :slug], unique: true
    add_column :scav_hunts, :slug, :text
    reversible do |dir|
      dir.up do
        remove_column :team_scav_hunts, :slug, :text, null: false
      end
      dir.down do
        add_column :team_scav_hunts, :slug, :text, null: true
        TeamScavHunt.all.each do |ts|
          ts.update(slug: ts.scav_hunt.slug)
        end
        change_column_null :team_scav_hunts, :slug, false
      end
    end
    reversible do |dir|
      dir.up do
        ScavHunt.all.each do |sh|
          sh.update(slug: sh.start.nil? ? sh.name.gsub(" ", "") : sh.start.to_date.year)
        end
      end
    end
    change_column_null :scav_hunts, :slug, false
    add_index :scav_hunts, :slug, unique: true
  end
end
