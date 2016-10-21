POINTS_TO_WIN = 5

module Displayable
  def display_welcome_message
    puts "#{human.name}, Welcome to Rock, Paper, Scissors, Spock, Lizard!"
    puts "You are playing #{computer.name}."
  end

  def display_choices
    puts("Enter letter for choice")
    puts("-- 'R' for rock (beats scissors and lizard)")
    puts("-- 'P' for paper (beats rock and spock)")
    puts("-- 'X' for scissors (beats paper and lizard)")
    puts("-- 'S' for spock (beats rock and scissors)")
    puts("-- 'L' for lizard (beats spock and paper)")
  end

  def display_moves
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def display_round_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif computer.move > human.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def display_score
    puts "-----------------------------------"
    puts "The score is:"
    puts "#{human.name}: #{human.score}"
    puts "#{computer.name}: #{computer.score}"
    puts "-----------------------------------"
  end

  def display_overall_winner
    if human.score > computer.score
      puts "#{human.name} won the whole game!"
    else
      puts "#{computer.name} won the whole game!"
    end
  end

  def display_player_strategy(player)
    puts "---------------------------------------"
    puts "#{player.name}'s strategy choices were:"
    puts "Rock: #{player.history[:rock]}"
    puts "Paper: #{player.history[:paper]}"
    puts "Scissors: #{player.history[:scissors]}"
    puts "Spock: #{player.history[:spock]}"
    puts "Lizard: #{player.history[:lizard]}"
  end

  def display_player_strategies
    display_player_strategy(human)
    display_player_strategy(computer)
  end

  def screen_clear
    system "clear"
  end

  def display_goodbye_message
    puts "Thanks for playing, Rock, Paper, Scissors, Spock, Lizard. Good bye!"
  end
end

#-------------------------------------------------------------------------------
class RPSGame
  include Displayable

  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.select
  end

  def update_score
    if human.move > computer.move
      human.score += 1
    elsif computer.move > human.move
      computer.score += 1
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ['y', 'n'].include? answer
      puts "Sorry, please enter y or n"
    end

    return true if answer == 'y'
    false
  end

  def end_of_game?
    (human.score == POINTS_TO_WIN) || (computer.score == POINTS_TO_WIN)
  end

  def reset_scores
    human.score = 0
    computer.score = 0
    computer.score_comparison = 0 if computer.class == Terminator
  end

  # increments history hash by converting player's move choice to a symbol
  def log_choices
    human.history[human.move.value.to_sym] += 1
    computer.history[computer.move.value.to_sym] += 1
  end

  def play_one_round
    human.choose
    screen_clear
    computer.choose
    log_choices
    display_moves
    display_round_winner
  end

  def play
    display_welcome_message
    loop do
      reset_scores
      until end_of_game?
        play_one_round
        update_score
        display_score
      end
      display_overall_winner
      break unless play_again?
    end
    display_player_strategies
    display_goodbye_message
  end
end

#------------------------------------------------------------------------------
class Player
  attr_accessor :move, :name, :score, :history

  def initialize
    set_name
    @score = 0
    @history = { rock: 0, paper: 0, scissors: 0, spock: 0, lizard: 0 }
  end
end

#------------------------------------------------------------------------------
class Human < Player
  include Displayable

  def set_name
    n = nil
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.strip.empty?
      puts "Sorry, must enter a value"
    end
    self.name = n
    screen_clear
  end

  def choose
    choice = nil
    loop do
      display_choices
      choice = gets.chomp.downcase.to_sym
      break if Move::VALID_CHOICES.keys.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(Move::VALID_CHOICES[choice])
  end
end

#------------------------------------------------------------------------------
class Computer < Player
  def self.select
    random_choice = rand(1..5)
    case random_choice
    when 1 then R2D2.new
    when 2 then Hal.new
    when 3 then Chappie.new
    when 4 then Sonny.new
    when 5 then Terminator.new
    end
  end

  def choose
    self.move = Move.new(Move::VALID_CHOICES.values.sample)
  end
end

#------------------------------------------------------------------------------
# Inherits choose method giving random move from parent Computer
class R2D2 < Computer
  def set_name
    self.name = self.class
  end
end

#------------------------------------------------------------------------------
# Always chooses rock
class Hal < Computer
  def set_name
    self.name = self.class
  end

  def choose
    self.move = Move.new('rock')
  end
end

#------------------------------------------------------------------------------
# Never repeats his last move
class Chappie < Computer
  def set_name
    self.name = self.class
  end

  def choose
    possible_moves = Move::VALID_CHOICES.values
    last_choice = if move.nil?
                    ''
                  else
                    move.value
                  end
    self.move = Move.new((possible_moves - [last_choice]).sample)
  end
end

#------------------------------------------------------------------------------
# Only chooses from original 3 move choices, favoring paper
class Sonny < Computer
  def set_name
    self.name = self.class
  end

  def choose
    choice = rand(1..10)
    case choice
    when (1..6)
      self.move = Move.new('paper')
    when (7..9)
      self.move = Move.new('scissors')
    when 10
      self.move = Move.new('rock')
    end
  end
end

#------------------------------------------------------------------------------
# Always chooses same move if it won the previous round, else chooses randomly
class Terminator < Computer
  attr_accessor :score_comparison

  def initialize
    super
    @score_comparison = 0
  end

  def set_name
    self.name = self.class
  end

  def choose
    if score > score_comparison
      self.score_comparison += 1
    else
      self.move = Move.new(Move::VALID_CHOICES.values.sample)
    end
  end
end

#------------------------------------------------------------------------------
class Move
  VALID_CHOICES = { r: 'rock', p: 'paper', x: 'scissors',
                    s: 'spock', l: 'lizard' }.freeze

  WIN_COMBOS = { rock: [:scissors, :lizard],
                 paper: [:rock, :spock],
                 scissors: [:paper, :lizard],
                 spock: [:rock, :scissors],
                 lizard: [:spock, :paper] }.freeze
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def to_s
    @value
  end

  def >(other_move)
    WIN_COMBOS[value.to_sym].include?(other_move.value.to_sym)
  end
end
#------------------------------------------------------------------------------

RPSGame.new.play
