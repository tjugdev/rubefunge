require "rubefunge"
require "optparse"

module Rubefunge
  class Exec

    def initialize(args)
      @args = args
      @options = {:runtime_opts => {}}
    end

    def parse
      option_parser = OptionParser.new do |opts|
        opts.banner = <<-EOF.gsub(/^ {10}/, '')
          Usage: #{$0} [options] FILE

          Description:
            Rubefunge is Befunge-93 compliant interpreter and debugger.

          Options:
        EOF
        opts.summary_width = 20   # Default width of options list column is very large...
        opts.on("-d", "--debug", "Execute FILE in an interactive debugger.") do
          @options[:debug] = true
        end
        opts.on("-h", "--help", "Show this message") do
          puts opts.help
          exit
        end
        opts.on("-n", "--new-line", "Print a new line after output.") do
          @options[:runtime_opts][:newline] = true
        end
      end

      option_parser.parse! @args

      if @args.length === 1
        file = @args[0]
        options = Options.new(@options[:runtime_opts])

        if @options[:debug]
          @interpreter = Debugger::Debugger.new(file, options)
        else
          @interpreter = Interpreter.new(file, options)
        end
      else
        raise ArgumentError, "Invalid arguments"
      end
    end

    def run
      @interpreter.run
    end

  end
end
