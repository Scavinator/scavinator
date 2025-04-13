class ItemsListCategoryPagesCheckConstraint < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      constraint_name = "list_category_or_page_number"
      dir.up do
        execute "ALTER TABLE items ADD CONSTRAINT #{constraint_name} CHECK (NOT (page_number IS NULL AND list_category_id IS NULL))"
      end
      dir.down do
        execute "ALTER TABLE items DROP CONSTRAINT #{constraint_name}"
      end
    end
  end
end
