# Create links table

class CreateLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :links do |t|
      t.string :title
      t.string :target_url
      t.string :short_code
      t.index :short_code

      t.timestamps
    end
  end
end
