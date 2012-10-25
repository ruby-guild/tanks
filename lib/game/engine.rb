class Game::Engine
  attr_reader :players

  def initialize
    @players = []
  end

  def add_player(name)
    player = Game::Player.new(name)
    @players << player
    player.id
  end

  def current_state
    {players: @players, objects: nil}
  end

  def change_state(action)
    player = @players.find {|p| p.id == action[:id]}
    player.do_command(action[:command])
  end
end
