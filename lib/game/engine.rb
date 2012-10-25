class Game::Engine
  attr_reader :players

  def initialize
    @players = []
  end

  def add_player(name)
    @players << Game::Player.new(name)
  end

  def current_state
    {players: @players, objects: nil}
  end

end
