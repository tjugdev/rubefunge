module Rubefunge
  class Options

    attr_accessor :newline

    @defaults = {
      :newline  => false,         # Should a new line be printed after output?
    }

    def self.defaults
      return @defaults
    end

    def initialize(opts = {})
      self.class.defaults.each {|k, v| instance_variable_set("@#{k}", opts.has_key?(k) ? opts[k] : v)}
    end

  end
end
