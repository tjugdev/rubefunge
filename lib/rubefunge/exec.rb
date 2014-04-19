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
          Usage: #{$0} [options] [INPUT]

          Description:
            Rubefunge is Befunge-93 compliant interpreter and debugger
            INPUT is a file, and is mandatory unless starting the debugger.

          Options:
        EOF
        opts.summary_width = 20   # Default width of options list column is very large...
        opts.on("-d", "--debug", "Execute program in an interactive debugger.") do
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

      file = @args.empty? ? :no_file : @args[0]
      options = Options.new(@options[:runtime_opts])

      if @options[:debug]
        @interpreter = Debugger::Debugger.new(file, options)
      elsif !@options[:debug] && file != :no_file
        @interpreter = Interpreter.new(file, options)
      else
        puts "Invalid arguments"
        puts option_parser.help
        exit false
      end
    end

    def run
      @interpreter.run
    end

  end
end
