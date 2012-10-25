describe Game::Player do
  it 'has position and direction vector' do
    subject.position.should be_an_instance_of(Game::Vector)
    subject.direction.should be_an_instance_of(Game::Vector)
  end

  it 'initialized with default position and direction' do
    subject.position.x.should == 0
    subject.position.y.should == 0
    subject.direction.x.should == 1
    subject.direction.y.should == 0
  end
end
