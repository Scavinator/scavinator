class ListCategoryAddSlug < ActiveRecord::Migration[8.0]
  def change
    add_column :list_categories, :slug, :text
    add_index :list_categories, :slug, unique: true
    ListCategory.all.each do |category|
      category.update(slug: category.name.downcase.gsub(" ", ""))
    end
    change_column_null :list_categories, :slug, false
  end
end
