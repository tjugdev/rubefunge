module Rubefunge
  class Stack
    def initialize(stack = [])
      @stack = stack
    end

    def push(value)
      @stack.push value
    end

    def pop
      @stack.empty? ? 0 : @stack.pop
    end

    def top
      @stack.empty? ? 0 : @stack.last
    end

    def tail(length)
      @stack.length <= length ? @stack : @stack.last(length)
    end

    def swap
      return unless @stack.length >= 2

      val1 = pop
      val2 = pop
      push val1
      push val2
    end

    def duplicate
      return unless @stack.length > 0

      push top
    end

    def to_a
      return @stack
    end
  end
end
