module ActionView
  module Helpers
    # Add the ability to pass a block to link_to
    #
    # Instead of creating the link name inline:
    #   <%= link_to haiku.text + haiku.created_at + haiku.user.username, haiku %>
    #
    # Pass a block for the link name:
    #   <%= link_to haiku do %>
    #     <%= haiku.text %>
    #     <%= haiku.created_at %>
    #     <%= haiku.user.username %>
    #   <% end %>
    module UrlHelper      
      # This currently only works in Haml views, and not helpers, due to a bug in Haml.
      def link_to_with_block(*args, &block)
        link_to_without_block(block_given? ? capture(&block) : args.shift, *args)
      end
      
      alias_method_chain :link_to, :block
    end
    
    module PrototypeHelper
      # This currently only works in Helpers, and not Haml views, due to a bug in Haml.
      def link_to_remote_with_block(*args, &block)
        link_to_remote_without_block(block_given? ? yield : args.shift, *args)
      end

      alias_method_chain :link_to_remote, :block
    end
  end
end