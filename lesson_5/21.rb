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
    puts 'Thanks for playing 21. Goodbye!'
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
  SUITS_CHAR = ["\u2665", "\u2666", "\u2660", "\u2663"].freeze
  VALUES = ['2', '3', '4', '5', '6', '7', '8', '9',
            'T', 'J', 'Q', 'K', 'A'].freeze

  attr_reader :cards

  def initialize
    @cards = []
    populate_deck
    shuffle_deck
  end

  def deal(participant)
    participant.hand << cards.pop
  end

  private

  def populate_deck
    4.times do |suit|
      13.times do |value|
        cards << Card.new(SUITS_CHAR[suit], VALUES[value])
      end
    end
  end

  def shuffle_deck
    cards.shuffle!
  end
end

class Card
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
  attr_accessor :winner

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def play
    display_welcome_message
    loop do
      loop do
        display_score
        deal_initial_cards
        display_hands
        participants_play
        determine_winner
        show_result
        update_score
        reset_game
        break if end_of_game?
      end
      display_overall_winner
      break unless play_again?
      reset_scores
    end
    display_goodbye_message
  end

  private

  def deal_initial_cards
    2.times do
      deck.deal(player)
      deck.deal(dealer)
    end
    dealer.hand[0].hide
  end

  def display_hands
    clear_screen
    display_hand(dealer)
    display_hand(player)
  end

  def display_hand(participant)
    puts "#{participant.name} is showing: #{participant.total} "
    participant.hand.size.times { print "  ______ " }
    puts ""
    participant.hand.size.times { |num| print " |#{participant.hand[num].suit}     |" }
    puts ""
    participant.hand.size.times { print " |      |" }
    puts ""
    participant.hand.size.times { |num| print " |  #{participant.hand[num].value}   |" }
    puts ""
    participant.hand.size.times { print " |      |" }
    puts ""
    participant.hand.size.times { |num| print " |_____#{participant.hand[num].suit}|" }
    puts ""
  end

  def player_turn
    while player.total <= GAME_TGT
      case player.choose_hit_or_stay
      when 'h'
        deck.deal(player)
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
      deck.deal(dealer)
      display_hands
    end
  end

  def determine_winner
    self.winner = if player.busted? || (dealer.total > player.total &&
                                       !dealer.busted?)
                    :dealer
                  elsif dealer.busted? || player.total > dealer.total
                    :player
                  else
                    :tie
                  end
  end

  def show_result
    if player.busted?
      puts "#{player.name} busted. #{dealer.name} wins!"
    elsif dealer.busted?
      puts "#{dealer.name} busted. #{player.name} wins!"
    elsif player.total > dealer.total
      puts "#{player.name} wins!"
    elsif dealer.total > player.total
      puts "#{dealer.name} wins!"
    else
      puts "It's a tie!"
    end
    sleep 4
  end

  def update_score
    player.score += 1 if winner == :player
    dealer.score += 1 if winner == :dealer
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
