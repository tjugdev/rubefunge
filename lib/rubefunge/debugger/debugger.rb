require "rubefunge/io"
require "rubefunge/engine"
require "rubefunge/options"
require "rubefunge/debugger/command_parser"

module Rubefunge
  module Debugger
    class Debugger

      attr_reader :io, :display, :breakpoints

      @@msg_prefixes = {:message => "", :warning => "Warning: ", :error => "Error: "}

      module PrintWithNewLine
        def print(*args)
          super(*args << "\n")
        end
      end

      def initialize(engine, options = Options.new, io = ::Rubefunge::IO.default)
        @options = options
        @engine = engine
        @io = io

        if @options.newline
          @engine.io.writer = @engine.io.writer.clone
          @engine.io.writer.extend PrintWithNewLine
        end

        @breakpoints = []
        @display = false
      end

      def cmd_prompt
        "#{@engine.step_no} > "
      end

      def process_input(input)
          begin
            cmd, argv = CommandParser.parse!(input)
            debug_cmd_process(cmd, argv)
            message("Program terminated.") if !@engine.running
          rescue ArgumentError, RuntimeError => e
            message(e.message, :error)
          end

        cmd == :quit
      end

      private
      def load_file(file)
        @engine.field = Playfield.from_file file
        reset
        message("#{file} loaded.")
      end

      def message(msg, type = :message)
        prefix = @@msg_prefixes[type]
        @io.print prefix, msg, "\n"
      end

      def reset
        @engine.reset
        message("Reset.")
      end

      def step
        if @engine.running
          @engine.step
        else
          message("Cannot step. No program running.")
        end
      end

      def info
        info = @engine.info(5)
        stringmode = info[:stringmode] ? "\tSTRINGMODE" : ""
        cmd = info[:current_character]
        cmd = "NOP" if cmd == " \t"
        return <<-EOF.gsub(/^ {8}/, '')
          cmd: #{cmd}\tpc: (#{info[:pc_x]}, #{info[:pc_y]})\tdir: #{info[:dir]}#{stringmode}
          stack top 5: #{info[:stack_top].to_s}
        EOF
      end

      def toggle_breakpoint(x, y)
        if x < 0 or y < 0 or x >= Playfield::FIELD_WIDTH or y >= Playfield::FIELD_HEIGHT
          message("Invalid location for breakpoint: (#{x}, #{y})")
        else
          loc = @breakpoints.index [x, y]
          if loc
            @breakpoints.delete_at(loc)
            message("Breakpoint removed.")
          else
            @breakpoints << [x, y]
            message("Breakpoint set.")
          end
        end
      end

      def list_breakpoints
        if @breakpoints.empty?
          message("No breakpoints set.")
        else
          message(@breakpoints.inject("Breakpoints found at:") {|acc, bp| acc << " (#{bp[0]}, #{bp[1]})"})
        end
      end

      def clear_breakpoints
        @breakpoints = []
        message("Breakpoints cleared.")
      end

      def run_to_break
        if !@engine.running
          message("Cannot run. Program has ended.")
        end

        while @engine.running
          step
          if @breakpoints.include? [@engine.pc_x, @engine.pc_y]
            message("Breakpoint found: (#{@engine.pc_x}, #{@engine.pc_y}).")
            return
          end
        end
      end

      # Execute command.  Validation for the number of arguments has already happened
      def debug_cmd_process(cmd, argv)
        argc = argv.length

        case cmd
          when :breakclear
            clear_breakpoints
          when :breaklist
            list_breakpoints
          when :break
            if argv[0] =~ /\d+/ && argv[1] =~ /\d+/
             toggle_breakpoint(argv[0].to_i, argv[1].to_i)
            else
              message("Arguments to '#{cmd.to_s}' must be positive integers.", :error)
            end
          when :display
            @display = !@display
          when :info
            @io.print info
          when :load
            if argc == 0
              reset
            else
              if File.file? argv[0]
                load_file(argv[0])
              else
                message("Cannot open #{argv[0]}. Does not exist.", :error)
              end
            end
          when :reload
            reset
          when :run
            run_to_break
            @io.print info if @display
          when :step
            count = argc === 0 ? 1 : argv[0].to_i
            message("Invalid argument '#{count}' for command '#{cmd.to_s}'.", :error) if count <= 0

            count.times {step}
            @io.print info if @display
        end
      end

    end
  end
end
