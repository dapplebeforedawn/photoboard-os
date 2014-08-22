class CreateMemories < ActiveRecord::Migration
  def change
    create_table :memories do |t|
      t.string :photo

      t.timestamps
    end
  end
end
