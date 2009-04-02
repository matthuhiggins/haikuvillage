module PublicHelper
  def fields_for_haiku
    fields_for :haiku do |haiku|
      concat(haiku.hidden_field(:text))
      concat(haiku.hidden_field(:subject_name))
      concat(haiku.hidden_field(:conversing_with))
      concat(haiku.hidden_field(:conversation_id))
    end
  end
end