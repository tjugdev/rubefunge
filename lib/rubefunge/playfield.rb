module Rubefunge
  class Playfield
    FIELD_WIDTH   = 80
    FIELD_HEIGHT  = 25

    def initialize(input = nil)
      @field = input.nil? ? [] : input.lines.map do |line|
        line = line.chomp.ljust FIELD_WIDTH
        line.slice!(FIELD_WIDTH..-1)
        line
      end
      @field.concat(Array.new(FIELD_HEIGHT - input.lines.length) {' ' * FIELD_WIDTH})
    end

    def get(x, y)
      return valid_pos?(x, y) ? @field[y][x] : 0
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
