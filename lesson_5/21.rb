class Participant
  attr_reader :hand
  attr_accessor :name
  
  def initialize
    # what would the "data" or "states" of a Player object entail?
    # maybe cards? a name?
    @hand = []
    set_name
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

  def hit
  end

  def stay
  end

  def busted?
  end

  def total
    sum = 0
    num_aces = 0
    hand.each do |card|
      case card.value
      when '2', '3', '4', '5', '6', '7', '8', '9' then sum += card.value.to_i
      when 'T', 'J', 'Q', 'K' then sum += 10
      when 'A'
        sum += 1
        num_aces += 1
      end
    end
    sum = ace_check(sum, num_aces) if num_aces > 0
    sum
  end
  
  private
  
  def ace_check(val, aces)
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
end

class Dealer < Participant
  def set_name
    self.name = ['Ace McQueen', 'Jack Bauer', 'Seven Costanza'].sample
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
  
  def deal
    cards.pop
  end
end

class Card
  attr_reader :suit, :value
  attr_accessor :hidden
  
  def initialize(suit, value)
    @suit = suit
    @value = value
  end
  
end

class Game
  GAME_TGT = 21
  DLR_STAY = 17
  
  attr_reader :deck, :player, :dealer
  
  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end
  
  def play
    display_welcome_message
    deal_initial_cards
    display_hands
    player_turn
    # dealer_turn
    # show_result
  end
  
  private
  def display_welcome_message
    puts "Welcome to 21, #{player.name}!"
    puts "Your dealer's name is #{dealer.name}."
  end
  
  def deal_initial_cards
    2.times do
      deal_card(player)
      deal_card(dealer)
    end
    dealer.hand[0].hidden = true
  end
  
  def deal_card(participant)
    participant.hand << deck.deal
  end
  
  def display_hands
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
        deal_card(player)
        display_hands
      when 's'
        break
      end
    end
  end
end

Game.new.play

# def player_choice
#   prompt("Would you like to hit or stay?")
#   answer = ''
#   loop do
#     prompt("Enter 'H' or 'S'")
#     answer = gets.chomp.downcase
#     break if answer == 'h' || answer == 's'
#     prompt("That's not a valid choice")
#   end
#   answer
# end

# def player_loop(d_cards, p_cards, totals, deck)
#   while totals[:player] <= GAME_TGT
#     case player_choice
#     when 'h'
#       p_cards = deal(deck, p_cards)
#       totals[:player] = value_calc(p_cards)
#       display_hands(d_cards, p_cards, totals, true)
#     when 's'
#       break
#     end
#   end
# end