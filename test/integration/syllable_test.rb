require 'test_helper'

class SyllableTest < ActionController::IntegrationTest
  # Replace this with your real tests.
  def test_syllable_count
    Lingua::EN::Syllable.syllables('testing')
  end
end
