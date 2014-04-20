require "test_helper"

class DebuggerCommandParserTest < MiniTest::Test

  def test_parse_blank_input
    assert_parsed_command("  ", :blank, [])
  end

  def test_parse_break
    assert_parsed_command("break 3 5", :break, ["3", "5"])
    assert_parsed_command("b 3 5", :break, ["3", "5"])
    assert_argument_error("b 1")
    assert_argument_error("b 1 3 6")
  end

  def test_parse_breakclear
    assert_parsed_command("breakclear", :breakclear, [])
    assert_parsed_command("bc", :breakclear, [])
    assert_argument_error("bc 3")
  end

  def test_parse_breaklist
    assert_parsed_command("breaklist", :breaklist, [])
    assert_parsed_command("bl", :breaklist, [])
    assert_argument_error("bl 3")
  end

  def test_parse_display
    assert_parsed_command("display", :display, [])
    assert_parsed_command("d", :display, [])
    assert_argument_error("d 3")
  end

  def test_parse_info
    assert_parsed_command("info", :info, [])
    assert_parsed_command("i", :info, [])
    assert_argument_error("i euaie")
  end

  def test_parse_load
    assert_parsed_command("load", :load, [])
    assert_parsed_command("l", :load, [])
    assert_parsed_command("load file.bf", :load, ["file.bf"])
    assert_parsed_command("l other_file.bf", :load, ["other_file.bf"])
    assert_parsed_command(%q{l "some \\\\ ugly *_ file\\""}, :load, [%q{some \\ ugly *_ file"}])
    assert_argument_error("l hcrho 35")
  end

  def test_parse_quit
    assert_parsed_command("quit", :quit, [])
    assert_parsed_command("q", :quit, [])
    assert_argument_error("q stuff")
  end

  def test_parse_reload
    assert_parsed_command("reload", :reload, [])
    assert_parsed_command("rl", :reload, [])
    assert_argument_error("rl eai")
  end

  def test_parse_run
    assert_parsed_command("run", :run, [])
    assert_parsed_command("r", :run, [])
    assert_argument_error("r eai")
  end

  def test_parse_step
    assert_parsed_command("step", :step, [])
    assert_parsed_command("s", :step, [])
    assert_parsed_command("step 3", :step, ["3"])
    assert_parsed_command("s 3", :step, ["3"])
    assert_argument_error("s 3 6")
  end

  def test_parse_unknown_command
    assert_raises(RuntimeError) {|e|
      Rubefunge::Debugger::CommandParser.parse!("notacommand")
      assert_equal("Unknown command: notacomand", e.message)
    }
  end

  private
  def assert_parsed_command(input, expected_cmd, expected_argv)
    cmd, argv = Rubefunge::Debugger::CommandParser.parse!(input)

    assert_equal(expected_cmd, cmd)
    assert_equal(expected_argv, argv)
  end

  def assert_argument_error(input)
    assert_raises(ArgumentError) { Rubefunge::Debugger::CommandParser.parse!(input) }
  end

end
