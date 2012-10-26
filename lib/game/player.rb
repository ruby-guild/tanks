class Game::Player
  DISTANCE = 0.1
  ANGLE = 0.01
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
        @move(DISTANCE)
      when :reverse
        @move(-DISTANCE)
      when :rotate_right
        @rotate(ANGLE)
      when :rotate_left
        @rotate(-ANGLE)
      when :shoot
        puts "Oh my gosh! He's fucking dangerous!"
    end
  end

  private

  def rotate(angle)
    x = @direcrion.x * Math.cos(angle) + @direction.y * Math.sin(angle)
    y = -@direction.x * Math.sin(angle) + @direction.y * Math.cos(angle)
    @direction.x, @direction.y = x, y
  end

  def move(distance)
    @position.x += @direction.x * distance
    @position.y += @direction.y * distance
  end

end
