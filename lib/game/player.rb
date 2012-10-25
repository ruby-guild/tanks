class Game::Player
  DISTANCE = 0.1
  attr_reader :position
  attr_reader :direction
  attr_reader :id

  def initialize(name="Anonymous", position=nil, direction=nil)
    @position ||= Game::Vector.new(0,0)
    @direction ||= Game::Vector.new(1,0)
    @id = SecureRandom.uuid
  end

  def do_command(command)
    case command
      when :accelerate
        @position.x += @direction.x * DISTANCE
        @position.y += @direction.y * DISTANCE
    end
  end
end
