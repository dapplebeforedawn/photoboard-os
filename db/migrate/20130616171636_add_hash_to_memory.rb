class AddHashToMemory < ActiveRecord::Migration
  def change
    add_column :memories, :md5hash, :string
  end
end
