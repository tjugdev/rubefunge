require "test_helper"

class PlayfieldTest < MiniTest::Test
  def test_play_field_gets_padded_to_full_size
    input = "v<\n>^"

    playfield =  Rubefunge::Playfield.new(input)

    expected_string = (["v<" << ' ' * 78 , ">^" << ' ' * 78] << [' ' * 80] * 23).join "\n"
    assert_equal(expected_string, playfield.to_s)
  end

  def test_play_field_gets_trimmed_if_too_large
    input = 'a' * 81

    playfield =  Rubefunge::Playfield.new(input)

    expected_string = (['a' * 80] << [' ' * 80] * 24).join "\n"
    assert_equal(expected_string, playfield.to_s)
  end

  def test_get_value
    input = "v<\n>^"

    playfield =  Rubefunge::Playfield.new(input)

    assert_equal('>', playfield.get(0, 1))
  end

  def test_put_value
    input = "v<\n>^"

    playfield =  Rubefunge::Playfield.new(input)
    playfield.put('*', 1, 0)

    assert_equal('*', playfield.get(1, 0))
  end
end
