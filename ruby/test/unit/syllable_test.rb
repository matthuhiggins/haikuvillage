require File.dirname(__FILE__) + '/../test_helper'

class SyllableTest < Test::Unit::TestCase
  EXPECTED_COUNTS = {
    :normal => {
      "matt"          => 1,
      "matthew"       => 2,
      "haiku"         => 2,
      "idea"          => 3,
      "uberific"      => 4,
      "strengths"     => 1
    },
    :letter => {
      "a"             => 1,
      "b"             => 1,
      "w"             => 3
    },
    :acronym => {
      'g.w.b.'        => 5,
      'GWB'           => 5,
      'gwb'           => 1,
      "r2d2"          => 4,
      "v12"           => 2
    },
    :punctuated => {
      "boy/girl"      => 2,
      "foo-bar"       => 2,
      "loser/g.w.b."  => 7
    },
    :possessive => {
      "matt's"        => 1,
      "foo's"         => 1,
      "faz's"         => 2,
      "96's"          => 4
    },
    :numeric => {
      "12"            => 1,
      "13"            => 2,
      "125"           => 7
    },
    :clock => {
      "3:15"          => 3,
      "1:00"          => 3
    },
    :ordinal => {
      "1st"           => 1,
      "2nd"           => 2,
      "3rd"           => 1,
      "12th"          => 1,
      "30th"          => 3,
      "100th"         => 3,
      "112th"         => 5,
      "122nd"         => 8
    }
  }
  
  def test_syllable_counts
    EXPECTED_COUNTS.values.each do |expectations|
      assert_expectations(expectations)
    end
  end
  
  def assert_expectations(expectations)
    expectations.each do |(word, expected)|
      assert_equal expected, word.syllables, "Expected #{expected} syllables for '#{word}', got #{word.syllables}"
    end  
  end
end