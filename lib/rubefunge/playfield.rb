module Rubefunge
  class Playfield
    FIELD_WIDTH   = 80
    FIELD_HEIGHT  = 25

    def initialize(input = nil)
      @field  = Array.new(FIELD_HEIGHT) {' ' * FIELD_WIDTH}
      if input != nil
        lines = input.split(/\r\n|\n|\r/)
        lines.each_index do |i|
          lines[i].rstrip!
          @field[i].insert(0, lines[i])
          @field[i].slice!(FIELD_WIDTH..-1)
          warn "Input line has been truncated" if lines[i].length > FIELD_WIDTH
        end
      end
    end

    def get(x, y)
      return valid_pos?(x, y) ? @field[y][x] : -1
    end

    def put(value, x, y)
      @field[y][x] = value if valid_pos?(x, y)
    end

    def to_s
      @field.join "\n"
    end

    private
    def valid_pos?(x, y)
      (x >= 0 and x < FIELD_WIDTH and y >= 0 and y < FIELD_HEIGHT)
    end
  end
end
