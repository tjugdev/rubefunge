module Rubefunge
  module Debugger
    class CommandParser

      def parse! input
        argv = input.scan(/"((?:\\.|[^"])*)"|(\S+)/).flatten.compact.map {|x| x.gsub(/\\(.)/, '\1')}
        cmd_str = argv.shift || ""

        case cmd_str.downcase
          when ""
            cmd = :blank
          when "break", "b"
            cmd = :break
            check_arguments(cmd, argv, [2])
          when "breakclear", "bc"
            cmd = :breakclear
            check_arguments(cmd, argv, [0])
          when "breaklist", "bl"
            cmd = :breaklist
            check_arguments(cmd, argv, [0])
          when "display", "d"
            cmd = :display
            check_arguments(cmd, argv, [0])
          when "info", "i"
            cmd = :info
            check_arguments(cmd, argv, [0])
          when "load", "l"
            cmd = :load
            check_arguments(cmd, argv, [0, 1])
          when "quit", "q"
            cmd = :quit
            check_arguments(cmd, argv, [0])
          when "reload", "rl"
            cmd = :reload
            check_arguments(cmd, argv, [0])
          when "run", "r"
            cmd = :run
            check_arguments(cmd, argv, [0])
          when "step", "s"
            cmd = :step
            check_arguments(cmd, argv, [0, 1])
          else
            raise RuntimeError, "Unknown command: #{cmd_str}"
        end
        return cmd, argv
      end

      private
      def check_arguments(cmd, argv, expected)
        unless expected.include? argv.length
          raise ArgumentError, "Command #{cmd.to_s} requires #{expected.join(' or ')} arguments but found #{argv.length}"
        end
      end

    end
  end
end
