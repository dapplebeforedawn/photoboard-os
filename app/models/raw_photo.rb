class RawPhoto
  AWS::S3::Base.establish_connection!(
    access_key_id:      UPLOADERS::CONFIG[:aws_key],
    secret_access_key:  UPLOADERS::CONFIG[:aws_secret]
  )

  PREFIX = 'raw/'
  attr_accessor :object

  def self.files
    files = AWS::S3::Bucket.objects UPLOADERS::CONFIG[:bucket], prefix: PREFIX
    files.delete_if { |aws_file| aws_file.key.match /^#{PREFIX}$/}
    files.map { |aws_file| new(aws_file) }
  end

  def self.size
    files.size
  end

  def self.find_by_key key
     new AWS::S3::S3Object.find key, UPLOADERS::CONFIG[:bucket]
  end

  def initialize(object)
    self.object = object
  end

  def key
    self.object.key
  end

  def url
    object.url
  end

  def process!
    memory = Memory.new(remote_photo_url: url)
    if memory.save
      object.delete
    elsif memory.errors[:md5hash].present?
      puts "Duplicate Upload: #{memory.inspect}"
      object.delete
    end
  end
end

