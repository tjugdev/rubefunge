require "rubefunge/engine"
require "rubefunge/options"

module Rubefunge
  class Interpreter

    def initialize(file = :no_file, options = {})
      @options = Options.new(options)
      @filename = :nofile

      init_engine file
    end

    def load_field(file = @filename)
      if file != :no_file and !File.file? file
        raise StandardError, "Cannot open #{file}.  Does not exist."
      end

      @filename = file
      input = File.open(file, "r") {|f| f.read} unless @filename == :no_file
      Playfield.new(input)
    end

    def init_engine file
      @playfield = load_field(file)
      @engine = get_engine @playfield
      @engine.reset
    end

    def get_engine playfield
      Engine.new playfield
    end

    # Run program from beginning to end.
    def run
      @engine.run
      puts if @options.newline
    end

  end
end
