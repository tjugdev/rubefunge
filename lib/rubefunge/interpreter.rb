require "rubefunge/io"
require "rubefunge/engine"
require "rubefunge/options"

module Rubefunge
  class Interpreter

    def initialize(engine, options = Options.new, io = ::Rubefunge::IO.default)
      @options = options
      @engine = engine
      @io = io
    end

    def run!
      @engine.run
      @io.print "\n" if @options.newline
    end

  end
end
