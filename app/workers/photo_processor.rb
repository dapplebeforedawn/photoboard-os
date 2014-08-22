# app/workers/hard_worker.rb
class PhotoProcessor
  include Sidekiq::Worker
  sidekiq_options :backtrace => true

  def perform(key)
    RawPhoto.find_by_key(key).process!
  end
end

