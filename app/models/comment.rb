class Comment < ActiveRecord::Base
  attr_accessible :memory_id, :text, :user_id
  belongs_to :memory
  belongs_to :user
end
