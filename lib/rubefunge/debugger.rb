require "rubefunge/interpreter"
require "rubefunge/debugger_command_parser"

module Rubefunge
  module Debugger
    class Debugger < Interpreter

      @msg_prefixes = {:message => "", :warning => "Warning: ", :error => "Error: "}

      module PrintWithNewLine
        def print(*args)
          super(*args)
          puts
        end
      end

      def initialize(file, options = {})
        super

        @breakpoints = []
        @display = false
        @stepno = 0

        @command_parser = CommandParser.new
      end

      def self.msg_prefixes
        return @msg_prefixes
      end

      def load_field(file = @filename)
        playfield = super
        message("#{file} loaded.") unless file == :no_file

        playfield
      end

      def get_engine playfield
        writer = $stdout
        writer.extend PrintWithNewLine if @options.newline

        Engine.new(playfield, writer)
      end

      def reset
        if @filename != :no_file
          @engine.reset

          @stepno = 0
          message("#{@filename} reset.")
        else
          message("No program loaded.")
        end
      end

      def step
        if @engine.running
          @engine.step
          @stepno += 1
          message("Program terminated.") if !@engine.running
        else
          message("Cannot step. No program running.")
        end
      end

      def run
        begin
          print "#{@stepno} > "
          input = STDIN.gets.chomp
          begin
            cmd, argv = @command_parser.parse!(input)
            debug_cmd_process(cmd, argv)
          rescue ArgumentError, RuntimeError => e
            message(e.message, :error)
          end
        end until cmd == :quit
      end

      def message(msg, type = :message)
        prefix = self.class.msg_prefixes[type]
        print prefix, msg, "\n"
      end

      private
      def info
        dirs = ["up", "right", "down", "left"]
        stringmode = @engine.stringmode ? "\tSTRINGMODE" : ""
        cmd = @engine.field.get(@engine.pc_x, @engine.pc_y)
        cmd = "NOP" if cmd == " \t"
        return <<-EOF.gsub(/^ {8}/, '')
          cmd: #{cmd}\tpc: (#{@engine.pc_x}, #{@engine.pc_y})\tdir: #{dirs[@engine.dir]}#{stringmode}
          stack top 5: #{@engine.stack.tail(5).to_s}
        EOF
      end

      def toggle_breakpoint(x, y)
        if x < 0 or y < 0 or x >= Playfield::FIELD_WIDTH or y >= Playfield::FIELD_HEIGHT
          message "Invalid location for breakpoint: (#{x}, #{y})"
        else
          loc = @breakpoints.index [x, y]
          if loc
            @breakpoints.delete_at(loc)
            message "Breakpoint removed."
          else
            @breakpoints << [x, y]
            message "Breakpoint set."
          end
        end
      end

      def list_breakpoints
        if @breakpoints.empty?
          message "No breakpoints set."
        else
          print "Breakpoints found at: "
          @breakpoints.each do |bp|
            x, y = bp
            print "(#{x}, #{y})  "
          end
          puts
        end
      end

      def run_to_break
        if !@engine.running
          message "Cannot run. Program has ended."
        end

        while @engine.running
          step
          if @breakpoints.include? [@engine.pc_x, @engine.pc_y]
            message "Breakpoint found: (#{@engine.pc_x}, #{@engine.pc_y})."
            return
          end
        end
      end

      # Execute command.  Validation for the number of arguments has already happened
      def debug_cmd_process(cmd, argv)
        argc = argv.length

        case cmd
          when :break_clear
            @breakpoints = []
          when :break_list
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
            print info
          when :load
            if argc == 0
              reset
            else
              if File.file? argv[0]
                init_engine(argv[0])
                reset
              else
                message("Cannot open #{argv[0]}. Does not exist.", :error)
              end
            end
          when :reload
            reset
          when :run
            run_to_break
            print info if @display
          when :step
            count = argc === 0 ? 1 : argv[0].to_x
            if count <= 0
              message "Invalid argument '#{count}' for command '#{cmd.to_s}'.", :error
            else
              message "To many arguments for command '#{cmd.to_s}'.", :error
              return
            end
            count.times {step}
            print info if @display
        end
      end

    end
  end
end
