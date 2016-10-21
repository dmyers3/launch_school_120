class Person
  attr_accessor :dave
  def initialize
    @dave = Slacker.new_init
  end
end

class Slacker
  def initialize
    return Hipster.new
  end
  
  def self.new_init
    return Hipster.new
  end
end

class Hipster
  attr_accessor :style
  def initialize
    @style = 'none'
  end
end

sample = Person.new

p sample.dave.class if sample.dave.class == Hipster