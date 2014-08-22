class Memory < ActiveRecord::Base
  mount_uploader :photo, PhotoUploader
  attr_accessible :photo, :remote_photo_url, :title, :marked_for_delete_at

  validates_uniqueness_of :md5hash, if:  ->(m){m.photo_changed?}
  before_validation :compute_hash, if: ->(m){m.photo_changed?}

  has_many :comments

  def compute_hash
    self.md5hash = Digest::MD5.hexdigest(photo.read)
  end
end
