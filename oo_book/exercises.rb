class Vehicle
  attr_accessor :color
  attr_reader :year, :model
  
  @@number_of_vehicles = 0
  
  def self.gas_mileage(gallons, miles)
    puts "#{miles / gallons} miles per gallon of gas"
  end
  
  def self.number_of_vehicles
    puts "There are #{@@number_of_vehicles} vehicles created."
  end
  
  def initialize
    @@number_of_vehicles += 1
  end

  def speed_up(number)
    @speed += number
    puts "You accelerate #{number} mph"
  end
  
  def brake(number)
    @speed -= number
    puts "You decelerate #{number} mph"
  end
  
  def current_speed
    puts "You are going #{@speed} mph"
  end
  
  def shut_down
    @speed = 0
    puts "You're now in park."
  end
  
  def spray_paint(new_color)
    self.color = new_color
    puts "Your vehicle is now #{color}!"
  end
  
     private
     
     def age
      puts "The age of the vehicle is #{Time.now.year} - #{year}"
     
     end
    
    

end


module Haulable

  def haul_furniture(type)
    puts "You can haul a #{type} in your vehicle!"
  end
end


class MyTruck < Vehicle
  NUMBER_OF_DOORS = 2
  
  include Haulable
  
  def initialize(year, color, model)
    @year = year
    @color = color
    @model = model
    @speed = 0
  end
end



class MyCar < Vehicle
  NUMBER_OF_DOORS = 4
  
  def initialize(year, color, model)
    @year = year
    @color = color
    @model = model
    @speed = 0
  end
  
end

lumina = MyCar.new(1997, 'chevy lumina', 'white')
lumina.speed_up(20)
lumina.current_speed
lumina.speed_up(20)
lumina.current_speed
lumina.brake(20)
lumina.current_speed
lumina.brake(20)
lumina.current_speed
lumina.shut_down
lumina.current_speed
lumina.spray_paint('red')
Vehicle.number_of_vehicles
tahoe = MyTruck.new(2000, 'chevy tahoe', 'black')
tahoe.haul_furniture('couch')
puts MyTruck.ancestors