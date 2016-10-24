class Board
  INITIAL_MARKER = ' '
  PLAYER_MARKER = 'X'
  COMP_MARKER = 'O'
  
  def initialize
    @squares = {}
    (1..9).each { |num| @squares[num] = Square.new(INITIAL_MARKER) }
  end
  
  def get_square_at(key)
    @squares[key]
  end
end

class Square
  def initialize(marker)
    @marker = marker
  end
  
  def to_s
    @marker
  end
end

class Player
  def initialize
  end

  def mark
  end
end

class TTTGame
  attr_reader :brd
  
  def initialize
    @brd = Board.new
    @human = Player.new
    @computer = Player.new
  end
  
  def display_welcome_message
    puts "Welome to Tic Tac Toe!"
    puts ""
  end
  
  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe. Goodbye!"
  end
  
  def display_board
  # puts "You're the #{PLAYER_MARKER}, Computer is the #{COMP_MARKER}"
  puts ""
  puts "        |         |        "
  puts "   #{brd.get_square_at(1)}    |    #{brd.get_square_at(2)}    |    #{brd.get_square_at(3)}    "
  puts "        |         |        "
  puts "--------+---------+--------"
  puts "        |         |        "
  puts "   #{brd.get_square_at(4)}    |    #{brd.get_square_at(5)}    |    #{brd.get_square_at(6)}     "
  puts "        |         |        "
  puts "--------+---------+--------"
  puts "        |         |        "
  puts "   #{brd.get_square_at(7)}    |    #{brd.get_square_at(8)}    |    #{brd.get_square_at(9)}     "
  puts "        |         |        "
  puts ""
  end
    
    
  def play
    display_welcome_message
    loop do
      display_board
      human_moves
      break if someone_won? || board_full?

      computer_moves
      break if someone_won? || board_full?
    end
    # display_result
    display_goodbye_message
  end
end

game = TTTGame.new
game.play