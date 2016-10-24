class Board
  WINNING_COMBOS = [[1, 2, 3], [1, 4, 7], [1, 5, 9], [2, 5, 8],
                    [3, 5, 7], [3, 6, 9], [4, 5, 6], [7, 8, 9]].freeze

  def initialize
    @squares = {}
    reset
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "        |         |        "
    puts "   #{@squares[1]}    |    #{@squares[2]}    |    #{@squares[3]}    "
    puts "        |         |        "
    puts "--------+---------+--------"
    puts "        |         |        "
    puts "   #{@squares[4]}    |    #{@squares[5]}    |    #{@squares[6]}     "
    puts "        |         |        "
    puts "--------+---------+--------"
    puts "        |         |        "
    puts "   #{@squares[7]}    |    #{@squares[8]}    |    #{@squares[9]}     "
    puts '        |         |        '
  end
  # rubocop:enable Metrics/AbcSize

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  # returns winning marker or nil
  def winning_marker
    WINNING_COMBOS.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def reset
    (1..9).each { |num| @squares[num] = Square.new }
  end

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = ' '.freeze

  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def marked?
    marker != INITIAL_MARKER
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_reader :marker
  attr_accessor :score

  def initialize(marker)
    @marker = marker
    @score = 0
  end
end

class TTTGame
  HUMAN_MARKER = 'X'.freeze
  COMP_MARKER = 'O'.freeze
  FIRST_TO_MOVE = HUMAN_MARKER
  POINTS_TO_WIN = 3

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMP_MARKER)
    @current_marker = FIRST_TO_MOVE
  end

  def play_one_round
    
  end
  
  def play
    display_welcome_message
    clear
    loop do
      display_board

      loop do
        current_player_moves
        break if board.someone_won? || board.full?
        clear_screen_and_display_board if human_turn?
      end
      display_result
      update_score
      break if end_of_game?
      reset
      display_play_again_message
    end

    display_goodbye_message
  end

  private

  def display_welcome_message
    puts 'Welome to Tic Tac Toe!'
    puts ''
  end

  def display_goodbye_message
    puts 'Thanks for playing Tic Tac Toe. Goodbye!'
  end

  def display_board
    puts "You're the #{HUMAN_MARKER}, Computer is the #{COMP_MARKER}."
    puts ''
    board.draw
    puts ''
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = COMP_MARKER
    else
      computer_moves
      @current_marker = HUMAN_MARKER
    end
  end

  def human_turn?
    @current_marker == HUMAN_MARKER
  end
  
  def joinor(arr, join_char = ', ', last_word = 'or')
    arr[arr.length - 1] = "#{last_word} #{arr[arr.length - 1]}" if arr.size > 1
    arr.size == 2 ? arr.join(' ') : arr.join(join_char)
  end

  # rubocop:disable Metrics/AbcSize
  def human_moves
    square = nil
    loop do
      puts('Which square do you want to select?')
      puts "Choose a square (#{joinor(board.unmarked_keys)}): "
      puts('The numbers refer to the squares from left-right then top-bottom')
      puts("Ex: top-left is '1', top-right is '3' and bottom-right is '9'")
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts("That isn't a valid choice! Make sure that the square isn't taken")
    end
    board[square] = human.marker
  end
  # rubocop:enable Metrics/AbcSize

  def computer_moves
    board[board.unmarked_keys.sample] = computer.marker
  end

  def display_result
    display_board
    if board.winning_marker == HUMAN_MARKER
      puts 'You won!'
    elsif board.winning_marker == COMP_MARKER
      puts 'The Computer won.'
    else
      puts "It's a tie!"
    end
  end
  
  def end_of_game?
    (human.score == POINTS_TO_WIN) || (computer.score == POINTS_TO_WIN)
  end
  
  def update_score
    if board.winning_marker == HUMAN_MARKER
      human.score += 1
    elsif board.winning_marker == COMP_MARKER
      computer.score += 1
    end
  end

  def play_again?
    answer = nil
    loop do
      puts 'Would you like to play again? (y/n)'
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts 'Sorry, must be y or n'
    end
    answer == 'y'
  end

  def clear
    system 'clear'
  end

  def reset
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ''
  end
end

game = TTTGame.new
game.play
