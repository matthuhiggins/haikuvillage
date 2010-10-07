module Author::UniqueUsername
  extend ActiveSupport::Concern
  
  module ClassMethods
    def find_unique_username(email)
      original = email.gsub(/\@(.*)/, '').gsub(/[^A-Za-z0-9]/, '')
      username = original
      i = 0

      until where(username: username).empty?
        i += 1
        username = "#{original}#{i}"
      end

      username
    end
  end
end