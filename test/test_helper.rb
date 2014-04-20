require "rubefunge"
require "minitest/autorun"

class MiniTest::Test

  def mock_io
    ::Rubefunge::IO.new(Minitest::Mock.new, Minitest::Mock.new)
  end

end
