module Rubefunge
  class Stack
    def initialize
      @stack = []
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
      val1 = pop
      val2 = pop
      push val1
      push val2
    end

    def duplicate
      push top
    end
  end
end
