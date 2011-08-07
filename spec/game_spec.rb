require 'game'

describe Game do
  before(:each) do
    @game = Game.new
  end
  
  it "should score all gutter balls as 0" do
    @game.score("--------------------").should == 0
  end
  
  it "should score single rolls in each frame" do
    @game.score("9-"*10).should == 90
  end
  
  it "should score a spare without points in the next roll" do
    @game.score("5/" + "--"*9).should == 10 
  end

  it "should score a spare with points in the next roll" do
    @game.score("5/5-" + "--"*8).should == 20
  end
end

describe Parse do
  include Parse
  
  it "should parse score line into frames" do
    parse("--").should have(1).frame
    parse("----").should have(2).frame
  end
end

describe Frame do
  it "should score gutter rolls" do
    Frame.new("-", "-").score.should == 0
  end

  it "should score a frame with one gutter roll" do
    Frame.new("5", "-").score.should == 5
  end
  
  it "should score a frame with pins standing" do
    Frame.new("1","2").score.should == 3
  end
  
  it "should score a spare frame" do
    current_frame = Frame.new("3", "/")
    current_frame.next_frame = Frame.new("5", "-")
    current_frame.score.should == 15
  end
  
  # it "should score a strike frame" do
  #   current_frame = Frame.new("X")
  #   current_frame.next_frame
  # end
end