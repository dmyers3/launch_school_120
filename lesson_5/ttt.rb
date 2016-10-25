require 'pry'

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

  def [](key)
    @squares[key].marker
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
  attr_accessor :score, :name, :marker

  def initialize
    set_name
    @score = 0
  end
end

class Human < Player
  def set_name
    human_name = nil
    loop do
      puts "What's your name?"
      human_name = gets.chomp
      break unless human_name.strip.empty?
      puts "Sorry, must enter a value"
    end
    self.name = human_name
  end

  def set_marker
    human_marker = nil
    loop do
      puts "What marker would you like? Choose any non-blank character"
      human_marker = gets.chomp
      break unless human_marker.strip.empty? || human_marker.length != 1
      puts "Sorry, must enter a valid character"
    end
    self.marker = human_marker
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Chappie', 'Sonny', 'Terminator', 'Hal'].sample
  end
end

class TTTGame
  POINTS_TO_WIN = 3
  # Choose :human or :computer
  FIRST_TO_MOVE = :human

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Human.new
    @computer = Computer.new
    set_markers
    @current_marker = first_move
  end

  def play
    clear
    display_welcome_message
    loop do
      loop do
        play_one_round
        break if end_of_game?
      end
      display_overall_winner
      break unless play_again?
      reset_scores
      display_play_again_message
    end
    display_goodbye_message
  end

  private

  def set_markers
    human.set_marker
    computer.marker = if %w(o O 0).include?(human.marker)
                        'X'
                      else
                        'O'
                      end
  end

  def play_one_round
    display_score
    display_board
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
    display_board
    display_result
    update_score
    reset_board
  end

  def first_move
    if FIRST_TO_MOVE == :human
      human.marker
    else
      computer.marker
    end
  end

  def display_welcome_message
    puts "Welome to Tic Tac Toe, #{human.name}!"
    puts "You are playing #{computer.name}"
    puts "The first to #{POINTS_TO_WIN} wins!"
    puts ''
  end

  def display_overall_winner
    if human.score > computer.score
      puts "#{human.name} won the whole game!"
    else
      puts "#{computer.name} won the whole game!"
    end
  end

  def display_goodbye_message
    puts 'Thanks for playing Tic Tac Toe. Goodbye!'
  end

  def display_board
    puts "You're the #{human.marker}, Computer is the #{computer.marker}."
    puts ''
    board.draw
    puts ''
  end

  def display_score
    puts "-----------------------------------"
    puts "The score is:"
    puts "#{human.name}: #{human.score}"
    puts "#{computer.name}: #{computer.score}"
    puts "-----------------------------------"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = computer.marker
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def human_turn?
    @current_marker == human.marker
  end

  def joinor(arr, join_char = ', ', last_word = 'or')
    arr[arr.length - 1] = "#{last_word} #{arr[arr.length - 1]}" if arr.size > 1
    arr.size == 2 ? arr.join(' ') : arr.join(join_char)
  end

  # rubocop:disable Metrics/AbcSize
  def human_moves
    key = nil
    loop do
      puts('Which square do you want to select?')
      puts "Choose a square (#{joinor(board.unmarked_keys)}): "
      puts('The numbers refer to the squares from left-right then top-bottom')
      puts("Ex: top-left is '1', top-right is '3' and bottom-right is '9'")
      key = gets.chomp.to_i
      break if board.unmarked_keys.include?(key)
      puts("That isn't a valid choice! Make sure that the square isn't taken")
    end
    board[key] = human.marker
  end
  # rubocop:enable Metrics/AbcSize

  # 1st priority is to win, 2nd is to block human, 3rd is choose middle square,
  # last option is random square
  def computer_moves
    key = comp_win_key || comp_block_key || middle_square ||
          board.unmarked_keys.sample
    board[key] = computer.marker
  end

  # iterates through unmarked squares, seeing if there are any winning combos
  # where two squares in a line are marked with same marker and 3rd square in
  # line is empty. If so returns key, and if not returns nil
  def key_for_three_in_row(marker)
    board.unmarked_keys.each do |key|
      win_combos_with_key = Board::WINNING_COMBOS.select do |combo|
        combo.include?(key)
      end
      win_combos_wout_key = win_combos_with_key.map { |combo| combo - [key] }
      win_combos_wout_key.each do |array_check|
        return key if board[array_check[0]] == marker &&
                      board[array_check[1]] == marker
      end
    end
    nil
  end

  def middle_square
    return 5 if board.unmarked_keys.include?(5)
    nil
  end

  def comp_win_key
    key_for_three_in_row(computer.marker)
  end

  def comp_block_key
    key_for_three_in_row(human.marker)
  end

  def display_result
    if board.winning_marker == human.marker
      puts "#{human.name} won!"
    elsif board.winning_marker == computer.marker
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def end_of_game?
    (human.score == POINTS_TO_WIN) || (computer.score == POINTS_TO_WIN)
  end

  def update_score
    if board.winning_marker == human.marker
      human.score += 1
    elsif board.winning_marker == computer.marker
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

  def reset_board
    board.reset
    @current_marker = first_move
  end

  def reset_scores
    human.score = 0
    computer.score = 0
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ''
  end
end

game = TTTGame.new
game.play
