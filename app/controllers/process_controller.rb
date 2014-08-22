class ProcessController < ApplicationController

  def photo
    RawPhoto.files.each do |file|
      PhotoProcessor.perform_async file.key
    end
    redirect_to root_url
  end

end
