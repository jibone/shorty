class AddRememberTokenToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :remember_token, :string
  end
end
