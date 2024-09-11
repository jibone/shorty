class CreateLinkClicks < ActiveRecord::Migration[7.1]
  def change
    create_table :link_clicks do |t|
      t.references :link, foreign_key: true, index: true, null: false
      t.string :ip_address
      t.string :country
      t.string :region
      t.string :city
      t.string :device_type
      t.string :browser_name
      t.string :browser_version
      t.string :os_name
      t.string :os_version
      t.string :referer

      t.timestamps
    end
  end
end
