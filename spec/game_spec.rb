require 'game'

describe Game do
  let(:game) { Game.new }

  it "should score all gutter balls as 0" do
    game.score("--" * 10).should == 0
  end
  
  it "should score single rolls in each frame" do
    game.score("9-"*10).should == 90
  end
  
  it "should score a spare without points in the next roll" do
    game.score("5/" + "--"*9).should == 10 
  end

  it "should score a spare with points in the next roll" do
    game.score("5/5-" + "--"*8).should == 20
  end
  
  it "should score a strike without points in the next roll" do
    game.score("X" + "--"*9).should == 10
  end

  it "should score a strike with points in the next roll" do
    game.score("X" + "5-" + "--"*8).should == 20
  end
  
  it "should score three consequtive strikes" do
    game.score("XXX" + "--"*7).should == 60
  end
end

describe Parse do
  include Parse
  
  it "should parse dashes into frames" do
    parse("--").should have(1).frame
    parse("----").should have(2).frame
  end
  
  it "should parse strikes into frames" do
    parse("X").should have(1).frame
    parse("XX").should have(2).frames
    parse("X--").should have(2).frames
  end
end

describe Frame do
  context "gutter frame" do
    let(:frame) {Frame.new("-", "-")}
    it { frame.score.should == 0 }
    it { frame.score_of_first_roll.should == 0 }
    it { frame.score_of_next_two_rolls.should == 0 }
  end
  
  context "frame with the second roll being a gutter ball" do
    let(:frame) {Frame.new("5", "-")}
    it { frame.score.should == 5}
  end

  context "frame with pins standing" do
    let(:frame) {Frame.new("1", "2")}
    it { frame.score.should == 3 }
  end
  
  context "spare" do
    let(:frame) do
      current_frame = Frame.new("3", "/")
      current_frame.next_frame = Frame.new("5", "-")
      current_frame
    end
    
    it { frame.score.should == 15 }
    it { frame.score_of_first_roll.should == 3 }
    it { frame.score_of_next_two_rolls.should == 10 }
  end
  
  context "strike" do
    let(:frame) do
      current_frame = Frame.new("X", nil)
      current_frame.next_frame = Frame.new("5", "3")
      current_frame
    end
    
    it { frame.score.should == 18 }
    it { frame.score_of_first_roll.should == 10}
    it { frame.score_of_next_two_rolls.should == 15}    
  end
end