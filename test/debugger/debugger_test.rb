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
    test_parsed_command(:quit, []) do |done|
      assert(done)
    end
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
    test_parsed_command(:step, []) do |done|
      refute(done)
    end
  end

  def test_step_with_arguments
    @engine.expect(:running, true)
    @engine.expect(:step, nil)
    @engine.expect(:running, true)
    @engine.expect(:step, nil)
    test_parsed_command(:step, [2]) do |done|
      refute(done)
    end
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

    test_parsed_command(:info, []) do |done|
      refute(done)
    end
  end

  def test_reset
    @engine.expect(:reset, nil)
    @io.expect(:print, nil, ["", "Reset.", "\n"])

    test_parsed_command(:reload, []) do |done|
      refute(done)
    end
  end

  def test_load_with_no_arguments_resets
    @engine.expect(:reset, nil)
    @io.expect(:print, nil, ["", "Reset.", "\n"])

    test_parsed_command(:load, []) do |done|
      refute(done)
    end
  end

  private
  def test_parsed_command(cmd, argv, &block)
    @engine.expect(:running, true)
    Rubefunge::Debugger::CommandParser.stub(:parse!, [cmd, argv]) do
      done = @debugger.process_input("")
      yield done
    end
  end

end
