class Author
  module Bipolar
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

      def find_or_create_from_graph(fb)
        data = fb.graph.get('me')
        if author = find_by_email(data['email'])
          author.update_attribute(:fb_uid, fb.uid)
          author
        else
          fb.user.update_attributes(
            username: find_unique_username(data['email']),
            email: data['email']
          )
          fb.user
        end
      end

      def migrate(existing_author, facebook_author)
        facebook_author.haikus.each do |haiku|
          existing_author.haikus << haiku
        end

        facebook_author.messages.each do |message|
          message.update_attribute(:sender, existing_author) if message.sender == facebook_author
          message.update_attribute(:recipient, existing_author) if message.recipient == facebook_author
          existing_author.messages << message
        end

        facebook_author.favorites.each do |favorite|
          unless existing_author.favorites.exists?(haiku_id: favorite.haiku_id)
            existing_author.favorites << favorite
          else
            favorite.destroy
          end
        end

        facebook_author.friendships.each do |friendship|
          unless existing_author.friendships.exists?(friend_id: friendship.friend_id)
            existing_author.friendships << friendship
          else
            friendship.destroy
          end
        end

        facebook_author.reverse_friendships.each do |friendship|
          unless existing_author.reverse_friendships.exists?(author_id: friendship.author_id)
            existing_author.reverse_friendships << friendship
          else
            friendship.destroy
          end
        end

        facebook_author.destroy
        existing_author.update_attribute(:fb_uid, facebook_author.fb_uid)
      end
    end
  end
end