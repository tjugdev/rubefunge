require "rubefunge/interpreter"

module Rubefunge
  class Debugger < Interpreter
    @msg_prefixes = { :message => "", :warning => "Warning: ", :error => "Error: " }
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
      super
      message "#{file} loaded." unless file == :no_file
    end

    def reset
      if @filename != :no_file
        super
        @stepno = 0
        message "#{@filename} reset."
      else
        message "No program loaded."
      end
    end

    def step
      if @running
        super
        @stepno += 1
        message "Program terminated." if !@running
      else
        message "Cannot step. No program running."
      end
    end

    def run
      print "#{@stepno} > "
      input = STDIN.gets.chomp
      cmd, argv = debug_cmd_parse(input)
      until cmd == :quit
        debug_cmd_process(cmd, argv)
        print "#{@stepno} > "
        input = STDIN.gets.chomp
        cmd, argv = debug_cmd_parse(input)
      end
    end

    def message(msg, type = :message)
      prefix = self.class.msg_prefixes[type]
      print prefix, msg, "\n"
    end

    private
    def info
      dirs = ["up", "right", "down", "left"]
      stringmode = @stringmode ? "\tSTRINGMODE" : ""
      cmd = @field.get(@pc_x, @pc_y)
      cmd = "NOP" if cmd == " \t"
      return <<-EOF.gsub(/^ {8}/, '')
        cmd: #{cmd}\tpc: (#{@pc_x}, #{@pc_y})\tdir: #{dirs[@dir]}#{stringmode}
        stack top 5: #{@stack.tail(5).to_s}
      EOF
    end

    def toggle_breakpoint(x, y)
      loc = @breakpoints.index [x, y]
      if loc
        @breakpoints.delete_at(loc)
        message "Breakpoint removed."
      else
        @breakpoints << [x, y]
        message "Breakpoint set."
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
      if !@running
        message "Cannot run. Program has ended."
      end

      while @running
        step
        if @breakpoints.include? [@pc_x, @pc_y]
          message "Breakpoint found: (#{@pc_x}, #{@pc_y})."
          return
        end
      end
    end

    # Returns command symbol from debugger_cmds and a vector of arguments
    def debug_cmd_parse(str)
      argv = str.downcase.split(' ')
      cmd = argv.empty? ? :blank : self.class.debug_cmds[argv.shift]
      return cmd, argv
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
          if argv[0] =~ /-?\d+/ and argv[1] =~ /-?\d+/
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
            load_field(argv[0])
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

    # If @options.newline is set, then print we should be printing a new line after each output
    def interpreter_print(val)
      print val
      puts if @options.newline
    end
  end
end
