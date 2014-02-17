require 'test/unit'
require 'gibberish_detector'

class GibberishDetectorTest < Test::Unit::TestCase
  def test_gibberish
    gibberish = "asodfjasdf"
    assert_equal gibberish.gibberish?, true
  end
  def test_non_gibberish
    gibberish = "hello world"
    assert_equal gibberish.gibberish?, false
  end
end
