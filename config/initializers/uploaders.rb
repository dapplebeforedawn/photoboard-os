module UPLOADERS
  CONFIG = YAML.load_file("#{Rails.root}/config/uploaders.yaml").with_indifferent_access[Rails.env]
  CONFIG[:aws_secret] = ENV['AWS_SECRET']
  CONFIG[:aws_key] = ENV['AWS_KEY']
end

module CarrierWave
  module RMagick
 
    # Rotates the image based on the EXIF Orientation
    def fix_exif_rotation
      manipulate! do |img|
        img.auto_orient!
        img = yield(img) if block_given?
        img
      end
    end
  end
end
