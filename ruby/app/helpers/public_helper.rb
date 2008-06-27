module PublicHelper
  def deferred_haiku_form(*args)
    form_for(*args) do |f|
      fields_for :haiku do |haiku|
        concat(haiku.hidden_field(:text))
        concat(haiku.hidden_field(:subject_name))
        concat(haiku.hidden_field(:conversing_with))
      end
      yield(f)
    end
  end
end