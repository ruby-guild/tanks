class Game::Player
  attr_reader :position
  attr_reader :direction

  def initialize(name="Anonymous", position=nil, direction=nil)
    @position ||= Game::Vector.new(0,0)
    @direction ||= Game::Vector.new(1,0)
  end
end
