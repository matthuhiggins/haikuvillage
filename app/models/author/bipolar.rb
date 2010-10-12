class Author
  module Bipolar
    extend ActiveSupport::Concern

    module ClassMethods
      def migrate(target, source)
        source.haikus.each do |haiku|
          target.haikus << haiku
        end

        source.messages.each do |message|
          message.update_attribute(:sender, target) if message.sender == source
          message.update_attribute(:recipient, target) if message.recipient == source
          target.messages << message
        end

        source.favorites.each do |favorite|
          unless target.favorites.exists?(haiku_id: favorite.haiku_id)
            target.favorites << favorite
          else
            favorite.destroy
          end
        end

        source.friendships.each do |friendship|
          unless target.friendships.exists?(friend_id: friendship.friend_id)
            target.friendships << friendship
          else
            friendship.destroy
          end
        end

        source.reverse_friendships.each do |friendship|
          unless target.reverse_friendships.exists?(author_id: friendship.author_id)
            target.reverse_friendships << friendship
          else
            friendship.destroy
          end
        end

        source.destroy
      end
    end
  end
end