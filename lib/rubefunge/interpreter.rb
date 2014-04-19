require "rubefunge/engine"
require "rubefunge/options"

module Rubefunge
  class Interpreter

    def initialize(file, options)
      @options = options
      init_engine file
    end

    def init_engine file
      playfield = load_field(file)
      @engine = get_engine(playfield)
      @engine.reset
    end

    def load_field(file)
      raise RuntimeError, "File #{file} not found" unless File.file? file

      @filename = file
      input = File.open(file, "r") {|f| f.read}
      Playfield.new(input)
    end

    def get_engine playfield
      Engine.new(playfield)
    end

    # Run program from beginning to end.
    def run
      @engine.run
      puts if @options.newline
    end

  end
end
