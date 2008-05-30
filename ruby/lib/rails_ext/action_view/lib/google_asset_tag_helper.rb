module HaikuView
  module Helpers
    module GoogleAssetTagHelper
      GOOGLE_PATHS = {
        'prototype' => 'http://ajax.googleapis.com/ajax/libs/prototype/1.6.0.2/prototype',
        'effects'   => 'http://ajax.googleapis.com/ajax/libs/scriptaculous/1.8.1/effects'
      }
      
      def self.included(base)
        base.send :alias_method_chain, :expand_javascript_sources, :google unless ActionController::Base.consider_all_requests_local
      end
      
      def expand_javascript_sources_with_google(sources)
        google_sources, normal_sources = sources.partition { |source| GOOGLE_PATHS.include? source }
        GOOGLE_PATHS.values_at(*google_sources) + expand_javascript_sources_without_google(normal_sources)
      end
    end
  end
end