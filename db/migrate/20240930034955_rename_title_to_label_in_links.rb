class RenameTitleToLabelInLinks < ActiveRecord::Migration[7.1]
  def change
    rename_column :links, :title, :label
  end
end
