require "#{File.dirname(__FILE__)}/../test_helper"

class SyllableTest < ActionController::IntegrationTest
  # fixtures :your, :models

  # Replace this with your real tests.
  def test_syllable_count
    Lingua::EN::Syllable.syllables('testing')
  end
end
