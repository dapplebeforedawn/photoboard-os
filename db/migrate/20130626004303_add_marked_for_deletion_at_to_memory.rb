class AddMarkedForDeletionAtToMemory < ActiveRecord::Migration
  def change
    add_column :memories, :marked_for_delete_at, :datetime
  end
end
