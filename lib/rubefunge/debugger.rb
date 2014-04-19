require "rubefunge/interpreter"

module Rubefunge
  class Debugger < Interpreter

    @msg_prefixes = {:message => "", :warning => "Warning: ", :error => "Error: "}

    # See doc/debugger.txt for description and usage of debugger commands.
    @debug_cmds  = {
      ""        => :blank,
      "break"   => :break,
      "b"       => :break,
      "display" => :display,
      "d"       => :display,
      "info"    => :info,
      "i"       => :info,
      "load"    => :load,
      "l"       => :load,
      "quit"    => :quit,
      "q"       => :quit,
      "reload"  => :reload,
      "rl"      => :reload,
      "run"     => :run,
      "r"       => :run,
      "step"    => :step,
      "s"       => :step
    }
    @debug_cmds.default = :invalid_cmd

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
    end

    def self.msg_prefixes
      return @msg_prefixes
    end

    def self.debug_cmds
      return @debug_cmds
    end

    def load_field(file = @filename)
      playfield = super
      message "#{file} loaded." unless file == :no_file

      playfield
    end

    def get_engine playfield
      writer = $stdout
      writer.extend PrintWithNewLine if @options.newline

      Engine.new playfield, writer
    end

    def reset
      if @filename != :no_file
        @engine.reset

        @stepno = 0
        message "#{@filename} reset."
      else
        message "No program loaded."
      end
    end

    def step
      if @engine.running
        @engine.step
        @stepno += 1
        message "Program terminated." if !@engine.running
      else
        message "Cannot step. No program running."
      end
    end

    def run
      begin
        print "#{@stepno} > "
        input = STDIN.gets.chomp
        cmd, argv = debug_cmd_parse(input)
        debug_cmd_process(cmd, argv)
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

    # Returns command symbol from debugger_cmds and a vector of arguments
    def debug_cmd_parse(str)
      argv = str.scan(/"((?:\\.|[^"])*)"|(\S+)/).flatten.compact.map {|x| x.gsub(/\\(.)/, '\1')}
      cmd = argv.empty? ? :blank : self.class.debug_cmds[argv.shift]
      return cmd.downcase, argv
    end

    # Execute and validate all commands except for quit.
    def debug_cmd_process(cmd, argv)
      argc = argv.length
      case cmd
      when :blank
        return
      when :break
        if argc == 1
          case argv[0].downcase
          when "clear"; @breakpoints = []
          when "list";  list_breakpoints
          else
            message "Invalid argument to command '#{cmd.to_s}'.", :error
          end
        elsif argc == 2
          if argv[0] =~ /\d+/ and argv[1] =~ /\d+/
           toggle_breakpoint(argv[0].to_i, argv[1].to_i)
          else
            message "Arguments no '#{cmd.to_s}' must be integers.", :error
          end
        else
          message "Command '#{cmd.to_s}' requires 1 or 2 arguments.", :error
        end
      when :display
        @display = !@display
      when :info
        print info
      when :load
        if argc == 0
          reset
        elsif argc == 1
          if File.file? argv[0]
            init_engine argv[0]
            reset
          else
            message "Cannot open #{argv[0]}. Does not exist.", :error
          end
        else
          message "Too many arguments for command '#{cmd.to_s}'.", :error
          return
        end
      when :reload
        reset
      when :run
        run_to_break
        print info if @display
      when :step
        if argc == 0
          count = 1
        elsif argc == 1
          count = argv[0].to_i
          if count <= 0
            message "Invalid argument '#{argv[0]}' for command '#{cmd.to_s}'.", :error
            return
          end
        else
          message "To many arguments for command '#{cmd.to_s}'.", :error
          return
        end
        count.times {step}
        print info if @display
      when :invalid_cmd
        message "Invalid command.", :error
      end
    end

  end
end
