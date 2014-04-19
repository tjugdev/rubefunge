module Rubefunge
  class Options

    attr_accessor :filename, :newline

    @defaults = {
      :filename => :no_file,      # Name of file currently being interpreted
      :newline  => false,         # Should a new line be printed after output?
    }

    def self.defaults
      return @defaults
    end

    def self.valid_specs
      return @valid_specs
    end

    def initialize(opts = {})
      self.class.defaults.each {|k, v| instance_variable_set("@#{k}", opts.has_key?(k) ? opts[k] : v)}
    end

  end
end
