module Parse
  def parse(score_line)
    score_line.chars.each_slice(2).map {|a,b| Frame.new(a, b)}
  end
end

class Frame
  attr_writer :next_frame
  
  def initialize(first_roll, second_roll)
    @first_roll = first_roll
    @second_roll = second_roll
  end
  
  def first_roll
    @first_roll.to_i
  end
  
  def score
    if @second_roll == "/"
      10 + @next_frame.first_roll
    else
      @first_roll.to_i + @second_roll.to_i
    end
  end
end

class Game
  def score(score_line)
    frames = parse(score_line)
    frames.each_cons(2) {|current_frame, next_frame| current_frame.next_frame = next_frame}
    frames.inject(0) do |total_score, frame|
      total_score + frame.score
    end
  end
  
  private
  include Parse
end