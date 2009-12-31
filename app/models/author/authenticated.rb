require 'digest/sha1'

module Author::Authenticated
  def self.included(user)
    user.class_eval do
      before_save :encrypt_password

      attr_accessor :password
      attr_protected :hashed_password, :salt

      # validates_confirmation_of :password, :on => :create
      validates_presence_of     :password, :on => :create
      validates_presence_of     :password, :on => :update, :unless => Proc.new { |user| user.password.nil? }

      extend ClassMethods
      include InstanceMethods
    end
  end
  
  module ClassMethods
    def find_by_login!(login)
      find_by_login(login) || (raise ActiveRecord::RecordNotFound)
    end

    def find_by_login(login)
      send(login =~ /@/ ? :find_by_email : :find_by_username, login)
    end

    def authenticate(login, password)
      if (author = find_by_login(login)) && author.authenticate(password)
        author
      end
    end

    def encrypted_password(password, salt)
      string_to_hash = password + "haiku" + salt
      Digest::SHA1.hexdigest(string_to_hash)
    end
  end
  
  module InstanceMethods
    def authenticate(pwd)
      return false unless pwd.is_a?(String)
      self.hashed_password == self.class.encrypted_password(pwd, self.salt)
    end
  
    private
      def encrypt_password
        return if password.nil?
        self.salt = ActiveSupport::SecureRandom.base64(16)
        self.hashed_password = self.class.encrypted_password(self.password, self.salt)
        self.password = nil
      end
  end
end
