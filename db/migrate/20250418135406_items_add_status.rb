class ItemsAddStatus < ActiveRecord::Migration[8.0]
  def change
    type_name = "item_status"
    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES[type_name.to_sym] = { name: type_name }
    reversible do |dir|
      dir.up do
        execute "CREATE TYPE #{type_name} AS ENUM ('claimed', 'help', 'box')"
      end
      dir.down do
        execute "DROP TYPE #{type_name}"
      end
    end
    add_column :items, :status, type_name.to_sym
  end
end
