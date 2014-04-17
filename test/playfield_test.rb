require "test_helper"

class PlayfieldTest < MiniTest::Test
  def test_play_field_gets_padded_to_full_size
    input = "v<\n>^"

    playfield =  Rubefunge::Playfield.new(input)

    expected_string = (["v<" << ' ' * 78 , ">^" << ' ' * 78] << [' ' * 80] * 23).join "\n"
    assert_equal(expected_string, playfield.to_s)
  end
end
