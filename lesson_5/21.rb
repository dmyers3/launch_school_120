class Participant
  attr_reader :hand
  attr_accessor :name
  
  def initialize
    # what would the "data" or "states" of a Player object entail?
    # maybe cards? a name?
    @hand = []
    set_name
  end

  def hit
  end

  def stay
  end

  def busted?
  end

  def total
    # definitely looks like we need to know about "cards" to produce some total
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
  attr_reader :deck, :player, :dealer
  
  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end
  
  def play
    deal_initial_cards
    p player.hand
    p dealer.hand
    p deck.cards.length
    show_initial_cards
    # player_turn
    # dealer_turn
    # show_result
  end
  
  private
  
  def deal_initial_cards
    2.times do
      deal_card(player)
      deal_card(dealer)
    end
  end
  
  def deal_card(participant)
    participant.hand << deck.deal
  end
  
  def show_initial_cards
    dealer.hand[0].hidden = true
    display_cards(dealer)
    display_cards(player)
  end
  
  def display_cards(participant)
    puts "#{participant.name} is showing: "
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
end

Game.new.play