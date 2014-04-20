require "rubefunge/io"
require "rubefunge/engine"
require "rubefunge/options"

module Rubefunge
  class Interpreter

    def initialize(file, options, io = ::Rubefunge::IO.default)
      @options = options
      @io = io
      init_engine file
    end

    def init_engine file
      playfield = load_field(file)
      @engine = get_engine(playfield)
      @engine.reset
    end

    def load_field(file)
      @filename = file
      Playfield.from_file(file)
    end

    def get_engine playfield
      Engine.new(playfield, @io)
    end

    # Run program from beginning to end.
    def run
      @engine.run
      @io.print "\n" if @options.newline
    end

  end
end
