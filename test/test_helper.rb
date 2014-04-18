require "rubefunge"
require "minitest/autorun"

class MiniTest::Test

  def fail_test msg
    assert false, msg
  end

end
