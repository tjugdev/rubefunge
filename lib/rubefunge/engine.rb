require "rubefunge/stack"
require "rubefunge/playfield"

module Rubefunge
  class Engine

    UP    = 0
    RIGHT = 1
    DOWN  = 2
    LEFT  = 3

    attr_reader :running, :field, :pc_x, :pc_y, :dir, :stack, :stringmode

    def initialize(field, writer = $stdout, reader = $stdin)
      @running = false

      @field = field
      @writer = writer
      @reader = reader
    end

    # Reset program to be run from beginning.
    def reset
      @pc_x       = 0
      @pc_y       = 0
      @dir        = RIGHT
      # The stack is an INTEGER stack.  Any characters are pushed as their ASCII value
      @stack      = Stack.new
      @stringmode = false
      @running    = true
    end

    def step
      process_char @field.get(@pc_x, @pc_y)
      advance_pc
    end

    # Run program from beginning to end.
    def run
      reset
      while @running
        step
      end
    end

    private
    # Advances the pc to the next non-whitespace character, looping if needed
    def advance_pc
      case @dir
      when UP
        @pc_y -= 1
      when DOWN
        @pc_y += 1
      when LEFT
        @pc_x -= 1
      when RIGHT
        @pc_x += 1
      end
      @pc_y += Playfield::FIELD_HEIGHT if @pc_y < 0
      @pc_y -= Playfield::FIELD_HEIGHT if @pc_y >= Playfield::FIELD_HEIGHT
      @pc_x += Playfield::FIELD_WIDTH if @pc_x < 0
      @pc_x -= Playfield::FIELD_WIDTH if @pc_x >= Playfield::FIELD_WIDTH
    end

    # Executes command for for given character
    def process_char(char)
      if @stringmode
        if char == '"'
          @stringmode = false
        else
          @stack.push(char.ord)
        end
      else
        case char
        when ' '
        when '+'
          val1 = @stack.pop
          val2 = @stack.pop
          @stack.push(val2 + val1)
        when '-'
          val1 = @stack.pop
          val2 = @stack.pop
          @stack.push(val2 - val1)
        when '*'
          val1 = @stack.pop
          val2 = @stack.pop
          @stack.push(val2 * val1)
        when '/'
          val1 = @stack.pop
          val2 = @stack.pop
          if val1.zero?
            @writer.print "Attempting to divide #{val2} by zero.  What should the result be? "
            val1 = gets.to_i
          end
          @stack.push(val2 / val1)
        when '%'
          val1 = @stack.pop
          val2 = @stack.pop
          if val1.zero?
            @writer.print "Attempting to divide #{val2} by zero.  What should the result be? "
            val1 = gets.to_i
          end
          @stack.push(val2 % val1)
        when '!'
          val = @stack.pop
          @stack.push(val.nonzero? ? 0 : 1)
        when '`'
          val1 = @stack.pop
          val2 = @stack.pop
          @stack.push(val2 > val1 ? 1 : 0)
        when '^'
          @dir = UP
        when 'v'
          @dir = DOWN
        when '<'
          @dir = LEFT
        when '>'
          @dir = RIGHT
        when '?'
          @dir = rand(4)
        when '_'
          val = @stack.pop
          @dir = val.nonzero? ? LEFT : RIGHT
        when '|'
          val = @stack.pop
          @dir = val.nonzero? ? UP : DOWN
        when '"'
          @stringmode = true
        when ':'
          @stack.duplicate
        when '\\'
          @stack.swap
        when '$'
          @stack.pop
        when '.'
          val = @stack.pop
          @writer.print val
        when ','
          val = @stack.pop
          @writer.print val.chr
        when '#'
          advance_pc
        when 'g'
          y = @stack.pop
          x = @stack.pop
          @stack.push(@field.get(x, y).ord)
        when 'p'
          y = @stack.pop
          x = @stack.pop
          val = @stack.pop
          @field.put(val.chr, x, y)
        when '&'
          val = @reader.gets.chomp
          @stack.push(val.to_i)
        when '~'
          val = @reader.gets
          @stack.push(val.chr.ord)
        when '@'
          @running = false
        when '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
          @stack.push(char.to_i)
        end
      end
    end

  end
end
