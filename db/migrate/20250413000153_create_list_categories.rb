class CreateListCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :list_categories do |t|
      t.text :name, null: false
      t.references :team, foreign_key: true

      t.timestamps
    end
    add_reference :items, :list_category, foreign_key: true
    add_index :items, [:team_scav_hunt_id, :list_category_id, :number], unique: true, nulls_not_distinct: true
    remove_index :items, [:team_scav_hunt_id, :number], unique: true
  end
end
