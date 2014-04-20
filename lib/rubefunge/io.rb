module Rubefunge
  class IO

    attr_accessor :reader, :writer

    def self.default
      new($stdin, $stdout)
    end

    def initialize(reader, writer)
      @reader = reader
      @writer = writer
    end

    def gets
      @reader.gets
    end

    def print(*args)
      @writer.print(*args)
    end

  end
end
