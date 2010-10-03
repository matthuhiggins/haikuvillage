module ErrorsHelper
  def error_message_on(object, method, options = {})
    options.reverse_merge!(prepend: '', append: '')

    if (errors = object.errors[method]).presence
      content_tag(:div,
        (options[:prepend].html_safe << errors.first).safe_concat(options[:append]),
        class: 'error'
      )
    else
      ''
    end
  end
end

module ActionView
  module Helpers
    FormBuilder.class_eval do
      # TODO test
      def error_message_on(method, *args)
        @template.error_message_on(@object, method, *args)
      end
    end
  end
end