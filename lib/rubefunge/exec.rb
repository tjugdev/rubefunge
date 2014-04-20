require "rubefunge"
require "optparse"

module Rubefunge
  class Exec

    def initialize(args)
      @args = args
      @options = {:runtime_opts => {}}
    end

    def run!
      parse!

      if @args.length === 1
        file = @args[0]
        options = Options.new(@options[:runtime_opts])
        engine = Engine.new(Playfield.from_file(file))

        if @options[:debug]
          run_debugger(Debugger::Debugger.new(engine, options))
        else
          run_interpreter(Interpreter.new(engine, options))
        end
      else
        raise ArgumentError, "Invalid arguments"
      end
    end

    private
    def parse!
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
    end

    def run_interpreter(interpreter)
        interpreter.run!
    end

    def run_debugger(debugger)
      begin
        debugger.io.print debugger.cmd_prompt
        input = debugger.io.gets.chomp
        done = debugger.process_input(input)
      end until done
    end

  end
end
