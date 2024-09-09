class AddUniqueIndexToShortCode < ActiveRecord::Migration[7.1]
  def change
    add_index :links, :short_code, name: "index_unique_on_short_sode", unique: true
  end
end
