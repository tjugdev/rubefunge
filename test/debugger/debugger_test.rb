require "test_helper"
require "rubefunge/options"

class DebuggerTest < MiniTest::Test

  def setup
    @engine = Minitest::Mock.new
    @options = Rubefunge::Options.new
    @io = Minitest::Mock.new
    @debugger = Rubefunge::Debugger::Debugger.new(@engine, @options, @io)
  end

  def teardown
    assert(@engine.verify)
    assert(@io.verify)
  end

  def test_quit
    test_parsed_command(:quit, []) {|done| assert(done)}
  end

  def test_toggle_display
    test_parsed_command(:display, []) do |done|
      assert(@debugger.display)
      refute(done)
    end

    test_parsed_command(:display, []) do |done|
      refute(@debugger.display)
      refute(done)
    end
  end

  def test_step_with_no_arguments
    @engine.expect(:running, true)
    @engine.expect(:step, nil)
    test_parsed_command(:step, []) {|done| refute(done)}
  end

  def test_step_with_arguments
    @engine.expect(:running, true)
    @engine.expect(:step, nil)
    @engine.expect(:running, true)
    @engine.expect(:step, nil)
    test_parsed_command(:step, [2]) {|done| refute(done)}
  end

  def test_info
    @engine.expect(:info, {
      :dir => "right",
      :stringmode => true,
      :current_character => ".",
      :pc_x => 3,
      :pc_y => 29,
      :stack_top => [8, 5, 77, 0, 0]
    }, [5])

    expected_info = <<-EOF.gsub(/^ {4}/, '')
      cmd: .\tpc: (3, 29)\tdir: right\tSTRINGMODE
      stack top 5: [8, 5, 77, 0, 0]
    EOF
    @io.expect(:print, nil, [expected_info])

    test_parsed_command(:info, []) {|done| refute(done)}
  end

  def test_reset
    @engine.expect(:reset, nil)
    @io.expect(:print, nil, ["", "Reset.", "\n"])

    test_parsed_command(:reload, []) {|done| refute(done)}
  end

  def test_load_with_no_arguments_resets
    @engine.expect(:reset, nil)
    @io.expect(:print, nil, ["", "Reset.", "\n"])

    test_parsed_command(:load, []) {|done| refute(done)}
  end

  def test_toggle_breakpoint
    @io.expect(:print, nil, ["", "Breakpoint set.", "\n"])
    @io.expect(:print, nil, ["", "Breakpoint removed.", "\n"])

    test_parsed_command(:break, ['8', '2']) do |done|
      refute(done)
      assert_equal([[8, 2]], @debugger.breakpoints)
    end

    test_parsed_command(:break, ['8', '2']) do |done|
      refute(done)
      assert_equal([], @debugger.breakpoints)
    end
  end

  def test_list_and_clear_breakpoints
    @io.expect(:print, nil, ["", "Breakpoint set.", "\n"])
    @io.expect(:print, nil, ["", "Breakpoint set.", "\n"])
    @io.expect(:print, nil, ["", "Breakpoints found at: (8, 2) (4, 5)", "\n"])
    @io.expect(:print, nil, ["", "Breakpoints cleared.", "\n"])

    test_parsed_command(:break, ['8', '2'])
    test_parsed_command(:break, ['4', '5'])
    test_parsed_command(:breaklist, []) {|done| refute(done)}
    test_parsed_command(:breakclear, []) {|done| refute(done)}
  end

  private
  def test_parsed_command(cmd, argv, &block)
    @engine.expect(:running, true)
    Rubefunge::Debugger::CommandParser.stub(:parse!, [cmd, argv]) do
      done = @debugger.process_input("")
      yield done if block_given?
    end
  end

end
