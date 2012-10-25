require 'spec_helper'

describe Game::Engine do
  it 'initialized correctly' do
    subject.should_not be_nil
  end

  it 'has players' do
    subject.players.should_not be_nil
  end

  it 'can join new player' do
    subject.add_player('Bot')
    subject.players.length.should == 1
  end

  it 'has current_state' do
    subject.current_state.should_not be_nil
  end
end
