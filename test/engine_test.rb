require "test_helper"

class EngineTest < MiniTest::Test

  TIMEOUT_SECONDS = 1

  def test_add
    run_for '12+@' do |engine|
      assert_equal([3], engine.stack.to_a)
    end
  end

  def test_add
    run_for '52-@' do |engine|
      assert_equal([3], engine.stack.to_a)
    end
  end

  def test_multiply
    run_for '36*@' do |engine|
      assert_equal([18], engine.stack.to_a)
    end
  end

  def test_integer_divide
    run_for '53/@' do |engine|
      assert_equal([1], engine.stack.to_a)
    end
  end

  def test_modulo
    run_for '85%@' do |engine|
      assert_equal([3], engine.stack.to_a)
    end
  end

  def test_not_when_zero
    run_for '0!@' do |engine|
      assert_equal([1], engine.stack.to_a)
    end
  end

  def test_not_when_non_zero
    run_for '1!@' do |engine|
      assert_equal([0], engine.stack.to_a)
    end
  end

  def test_greater_than_when_true
    run_for '21`@' do |engine|
      assert_equal([1], engine.stack.to_a)
    end
  end

  def test_greater_than_when_false
    run_for '22`@' do |engine|
      assert_equal([0], engine.stack.to_a)
    end
  end

  def test_swap
    run_for '89\\@' do |engine|
      assert_equal([9, 8], engine.stack.to_a)
    end
  end

  def test_duplicate
    run_for '3:@' do |engine|
      assert_equal([3, 3], engine.stack.to_a)
    end
  end

  def test_numbers_are_pushed_onto_stack
    run_for '0123456789@' do |engine|
      expected_stack = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
      assert_equal(expected_stack, engine.stack.to_a)
    end
  end

  def test_string_is_pushed_onto_stack_as_ascii_values
    run_for '"pancakes"@' do |engine|
      expected_stack = "pancakes".chars.map(&:ord)
      assert_equal(expected_stack, engine.stack.to_a)
    end
  end

  def test_bridge
    run_for '0#12@' do |engine|
      assert_equal([0, 2], engine.stack.to_a)
    end
  end

  def test_print_value_as_decimal
    writer = MiniTest::Mock.new
    writer.expect(:print, nil, [7])

    run_for '7.@', writer do |engine|
      assert_equal([], engine.stack.to_a)
    end

    assert writer.verify
  end

  def test_print_value_as_character
    writer = MiniTest::Mock.new
    writer.expect(:print, nil, ['q'])

    run_for '"q",@', writer do |engine|
      assert_equal([], engine.stack.to_a)
    end

    assert writer.verify
  end

  def test_read_integer
    reader = MiniTest::Mock.new
    reader.expect(:gets, "812")

    run_for '&@', $stdout, reader do |engine|
      assert_equal([812], engine.stack.to_a)
    end

    assert reader.verify
  end

  def test_read_character
    reader = MiniTest::Mock.new
    reader.expect(:gets, "stuff")

    run_for '~@', $stdout, reader do |engine|
      assert_equal(['s'.ord], engine.stack.to_a)
    end

    assert reader.verify
  end

  def test_put_character
    run_for '"a"12p@' do |engine|
      assert_equal([], engine.stack.to_a)
      assert_equal('a', engine.field.get(1, 2))
    end
  end

  def test_get_character
    run_for '30g@' do |engine|
      assert_equal(['@'.ord], engine.stack.to_a)
    end
  end

  def test_directions
    field = <<-EOF.gsub(/^ {6}/, '')
      v  @3 <
      0     2
      > 1   ^
    EOF

    run_for field do |engine|
      assert_equal([0, 1, 2 ,3], engine.stack.to_a)
    end
  end

  def test_conditional_directions
    field = <<-EOF.gsub(/^ {6}/, '')
      00| @_
        1  1
        0  3
        _21|
    EOF

    run_for field do |engine|
      assert_equal([0, 1, 2, 3], engine.stack.to_a)
    end
  end

  def test_movement_wraps_around
    field = <<-EOF.gsub(/^ {6}/, '')
      v  1
       2^>
      < @v0
        3
    EOF

    run_for field do |engine|
      assert_equal([0, 1, 2, 3], engine.stack.to_a)
    end
  end

  private
  def run_for(input, writer = $stdout, reader = $stdout, &block)
    begin
      Timeout::timeout(TIMEOUT_SECONDS) {
        field = Rubefunge::Playfield.new(input)

        engine = Rubefunge::Engine.new(field, writer, reader)
        engine.run

        yield engine if block_given?
      }
    rescue Timeout::Error
      flunk("Test timed out.  Maybe caught in an infinite loop?")
    end
  end

end
