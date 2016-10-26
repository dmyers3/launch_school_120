require 'pry'

module Displayable
  def display_welcome_message
    clear_screen
    puts "Welcome to 21, #{player.name}!"
    puts "Your dealer's name is #{dealer.name}."
    puts "First to #{Game::POINTS_TO_WIN} wins!"
    sleep 3
  end

  def display_score
    puts "-----------------------------------"
    puts "The score is:"
    puts "#{player.name}: #{player.score}"
    puts "#{dealer.name}: #{dealer.score}"
    puts "-----------------------------------"
    sleep 3
  end

  def display_overall_winner
    if player.score > dealer.score
      puts "#{player.name} won the whole game!"
    else
      puts "#{dealer.name} won the whole game!"
    end
  end

  def display_goodbye_message
    puts 'Thanks for playing Twenty-One. Goodbye!'
  end

  def clear_screen
    system 'clear'
  end
end

class Participant
  attr_reader :total
  attr_accessor :name, :score, :hand

  def initialize
    @hand = []
    @score = 0
    set_name
  end

  def busted?
    total > Game::GAME_TGT
  end

  def total
    sum = 0
    num_aces = 0
    hand.each do |card|
      case card.value
      when '2', '3', '4', '5', '6', '7', '8', '9', ""
        sum += card.value.to_i
      when 'T', 'J', 'Q', 'K'
        sum += 10
      when 'A'
        sum += 1
        num_aces += 1
      end
    end
    sum = adjust_aces(sum, num_aces) if num_aces.positive?
    sum
  end

  private

  def adjust_aces(val, aces)
    aces.times { val += 10 if val <= 11 }
    val
  end
end

class Player < Participant
  def set_name
    player_name = nil
    loop do
      puts "What's your name?"
      player_name = gets.chomp
      break unless player_name.strip.empty?
      puts "Sorry, must enter a value"
    end
    self.name = player_name
  end

  def choose_hit_or_stay
    puts("Would you like to hit or stay?")
    answer = ''
    loop do
      puts("Enter 'H' or 'S'")
      answer = gets.chomp.downcase
      break if answer == 'h' || answer == 's'
      puts("That's not a valid choice")
    end
    answer
  end
end

class Dealer < Participant
  def set_name
    self.name = ['Ace McQueen', 'Jack Spade', 'Deuce Kingman'].sample
  end

  def flip_card
    puts "Dealer is flipping over his hidden card..."
    sleep 3
    hand[0].unhide
  end
end

class Deck
  attr_reader :cards

  def initialize
    @cards = []
    populate_deck
    shuffle_deck
  end

  def deal_one(participant)
    participant.hand << cards.pop
  end

  private

  def populate_deck
    Card::SUITS_CHAR.each do |suit|
      Card::VALUES.each do |value|
        cards << Card.new(suit, value)
      end
    end
  end

  def shuffle_deck
    cards.shuffle!
  end
end

class Card
  SUITS_CHAR = ["\u2665", "\u2666", "\u2660", "\u2663"].freeze
  VALUES = ['2', '3', '4', '5', '6', '7', '8', '9',
            'T', 'J', 'Q', 'K', 'A'].freeze

  attr_accessor :hidden_value, :hidden_suit, :suit, :value

  def initialize(suit, value)
    @suit = suit
    @value = value
  end

  def hide
    self.hidden_value = value
    self.hidden_suit = suit
    self.suit = " "
    self.value = " "
  end

  def unhide
    self.value = hidden_value
    self.suit = hidden_suit
  end
end

class Game
  include Displayable

  GAME_TGT = 21
  DLR_STAY = 17
  POINTS_TO_WIN = 3

  attr_reader :deck, :player, :dealer
  attr_accessor :result

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def play
    display_welcome_message
    loop do
      loop do
        play_one_round
        break if end_of_game?
      end
      display_overall_winner
      break unless play_again?
      reset_scores
    end
    display_goodbye_message
  end

  private

  def play_one_round
    display_score
    deal_initial_cards
    display_hands
    participants_play
    determine_result
    show_result
    update_score
    reset_game
  end

  def deal_initial_cards
    2.times do
      deck.deal_one(player)
      deck.deal_one(dealer)
    end
    dealer.hand[0].hide
  end

  def display_hands
    clear_screen
    display_hand(dealer)
    display_hand(player)
  end

  # rubocop:disable Metrics/AbcSize
  def display_hand(plyr)
    puts "#{plyr.name} is showing: #{plyr.total} "
    plyr.hand.size.times { print "  ______ " }
    puts ""
    plyr.hand.size.times { |num| print " |#{plyr.hand[num].suit}     |" }
    puts ""
    plyr.hand.size.times { print " |      |" }
    puts ""
    plyr.hand.size.times { |num| print " |  #{plyr.hand[num].value}   |" }
    puts ""
    plyr.hand.size.times { print " |      |" }
    puts ""
    plyr.hand.size.times { |num| print " |_____#{plyr.hand[num].suit}|" }
    puts ""
  end
  # rubocop:enable Metrics/AbcSize

  def player_turn
    while player.total <= GAME_TGT
      case player.choose_hit_or_stay
      when 'h'
        deck.deal_one(player)
        display_hands
      when 's'
        break
      end
    end
  end

  def participants_play
    player_turn
    return if player.busted?
    dealer_turn
  end

  def dealer_turn
    dealer.flip_card
    display_hands
    while dealer.total < DLR_STAY
      sleep 2
      deck.deal_one(dealer)
      display_hands
    end
  end

  def determine_result
    self.result = if player.busted?
                    :bust
                  elsif dealer.busted?
                    :dealer_bust
                  elsif player.total > dealer.total
                    :win
                  elsif dealer.total > player.total
                    :lose
                  else
                    :tie
                  end
  end

  def show_result
    case result
    when :bust
      puts "#{player.name} busted. #{dealer.name} wins!"
    when :dealer_bust
      puts "#{dealer.name} busted. #{player.name} wins!"
    when :win
      puts "#{player.name} wins!"
    when :lose
      puts "#{dealer.name} wins!"
    else
      puts "It's a tie!"
    end
    sleep 2
  end

  def update_score
    player.score += 1 if result == :win || result == :dealer_bust
    dealer.score += 1 if result == :lose || result == :bust
  end

  def end_of_game?
    (player.score == POINTS_TO_WIN) || (dealer.score == POINTS_TO_WIN)
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

  def reset_game
    @deck = Deck.new
    player.hand = []
    dealer.hand = []
  end

  def reset_scores
    player.score = 0
    dealer.score = 0
  end
end

Game.new.play
