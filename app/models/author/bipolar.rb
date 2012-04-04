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

      def find_or_create_by_facebook(fb_uid, graph)
        facebook_author = find_or_initialize_by_fb_uid(fb_uid)

        if facebook_author.persisted?
          facebook_author
        else
          data = graph.get_object('me')

          if existing_author = Author.find_by_email(data['email'])
            existing_author.update_attribute(:fb_uid, fb_uid)
            existing_author
          else
            facebook_author.update_attributes(
              username: find_unique_username(data['email']),
              email: data['email'],
            )
            facebook_author
          end
        end
      end

      def migrate(existing_author, other_author)
        other_author.haikus.each do |haiku|
          existing_author.haikus << haiku
        end

        other_author.messages.each do |message|
          message.update_attribute(:sender, existing_author) if message.sender == other_author
          message.update_attribute(:recipient, existing_author) if message.recipient == other_author
          existing_author.messages << message
        end
        Message.where(sender_id: other_author).delete_all
        Message.where(recipient_id: other_author).delete_all

        other_author.favorites.each do |favorite|
          unless existing_author.favorites.exists?(haiku_id: favorite.haiku_id)
            existing_author.favorites << favorite
          else
            favorite.destroy
          end
        end

        other_author.friendships.each do |friendship|
          unless existing_author.friendships.exists?(friend_id: friendship.friend_id)
            existing_author.friendships << friendship
          else
            friendship.destroy
          end
        end

        other_author.reverse_friendships.each do |friendship|
          unless existing_author.reverse_friendships.exists?(author_id: friendship.author_id)
            existing_author.reverse_friendships << friendship
          else
            friendship.destroy
          end
        end

        other_author.destroy
        existing_author.update_attribute(:fb_uid, other_author.fb_uid)
      end
    end
  end
end