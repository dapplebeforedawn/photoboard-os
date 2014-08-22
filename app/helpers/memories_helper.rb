module MemoriesHelper
  def name_only email
    email.split('@')[0]
  end
end
