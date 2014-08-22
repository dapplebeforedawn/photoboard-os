class AddTitleToMemory < ActiveRecord::Migration
  def change
    add_column :memories, :title, :string
  end
end
