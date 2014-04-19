require "test_helper"

class StackTest < MiniTest::Test

  def test_push
    stack = Rubefunge::Stack.new [1 ,2 ,3]

    stack.push 6

    assert_equal([1, 2, 3, 6], stack.to_a)
  end

  def test_pop_stack_returns_top_and_removes
    stack = Rubefunge::Stack.new [1, 2 ,3]

    popped_val = stack.pop

    assert_equal(3, popped_val)
    assert_equal([1, 2], stack.to_a)
  end

  def test_pop_empty_stack_returns_zero
    stack = Rubefunge::Stack.new []

    popped_val = stack.pop

    assert_equal(0, popped_val)
    assert_equal([], stack.to_a)
  end

  def test_top_returns_top_element_without_changing_stack
    stack = Rubefunge::Stack.new [1, 2, 3]

    top_val = stack.top

    assert_equal(3, top_val)
    assert_equal([1, 2, 3], stack.to_a)
  end

  def test_top_of_empty_stack_is_zero_and_doesnt_change_stack
    stack = Rubefunge::Stack.new []

    top_val = stack.top

    assert_equal(0, top_val)
    assert_equal([], stack.to_a)
  end

  def test_tail_when_stack_has_enough_elements
    stack = Rubefunge::Stack.new [1, 3, 5, 9, 11]

    tail = stack.tail(3)

    assert_equal([5, 9, 11], tail)
  end

  def test_tail_when_stack_does_not_have_enough_elements
    stack = Rubefunge::Stack.new [1, 3]

    tail = stack.tail(3)

    assert_equal([1, 3], tail)
  end

  def test_swap_when_stack_has_at_least_two_elements
    stack = Rubefunge::Stack.new [1, 2, 3]

    stack.swap

    assert_equal([1, 3, 2], stack.to_a)
  end

  def test_swap_when_stack_has_fewer_than_two_elements
    stack = Rubefunge::Stack.new [1]

    stack.swap

    assert_equal([1], stack.to_a)
  end

  def test_duplicate_when_stack_is_non_empty
    stack = Rubefunge::Stack.new [1, 2, 3]

    stack.duplicate

    assert_equal([1, 2, 3, 3], stack.to_a)
  end

  def test_duplicate_when_stack_is_empty
    stack = Rubefunge::Stack.new []

    stack.duplicate

    assert_equal([], stack.to_a)
  end

end
