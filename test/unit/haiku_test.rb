require 'test_helper'

class HaikuTest < ActiveSupport::TestCase
  test 'to_param' do
    haiku = Factory(:haiku, text: "the quick brown fox jumped\nover the lazy dog. cool\nfive more syllables")
    assert_equal(
      "#{haiku.id}-the-quick-brown-fox-jumped",
      haiku.to_param
    )
  end
end