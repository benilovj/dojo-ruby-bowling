module Parse
  def parse(score_line)
    score_chars = score_line.chars.to_a
    frames = []
    
    until score_chars.empty?
      frames << pop_frame(score_chars, frames.size == 9)
    end
    frames
  end
  
  def pop_frame(score_chars, is_last)
    return  ExtendedLastFrame.new(*(score_chars.shift 3)) if is_last and score_chars.size == 3

    first_roll = score_chars.shift
    return StrikeFrame.new if first_roll == 'X'

    second_roll = score_chars.shift
    return SpareFrame.new(first_roll) if second_roll == "/"
    
    Frame.new(first_roll, second_roll)
  end  
end

class Frame
  attr_writer :next_frame
  
  def initialize(first_roll, second_roll = nil)
    @first_roll = first_roll
    @second_roll = second_roll
  end
  
  def score
    @first_roll.to_i + @second_roll.to_i
  end
  
  def score_of_first_roll
    @first_roll.to_i
  end
  
  def score_of_next_two_rolls
    @first_roll.to_i + @second_roll.to_i
  end
  
end

class SpareFrame 
  attr_writer :next_frame
  
  def initialize(first_roll)
    @first_roll = first_roll
  end
  
  def score
    10 + @next_frame.score_of_first_roll
  end
  
  def score_of_first_roll
    @first_roll.to_i
  end
  
  def score_of_next_two_rolls
    10
  end
end

class StrikeFrame
  attr_writer :next_frame
  
  def score
    10 + @next_frame.score_of_next_two_rolls
  end
  
  def score_of_first_roll
    10
  end
  
  def score_of_next_two_rolls
    10 + @next_frame.score_of_first_roll
  end
end

class ExtendedLastFrame
  def initialize(*rolls)
    @rolls = rolls
  end
  
  def score
    scores.inject(:+)
  end
  
  def score_of_first_roll
    scores[0]
  end
  
  def score_of_next_two_rolls
    scores[0..1].inject(:+)
  end
  
  protected
  def scores
    scores = @rolls.map {|roll| roll == "X" ? 10 : roll}
    scores[1] = 10 - scores[0].to_i if scores[1] == "/"
    scores[2] = 10 - scores[1].to_i if scores[2] == "/"
    scores.map(&:to_i)
  end
end

class Game
  def score(score_line)
    frames = parse(score_line)
    link_to_next(frames)
    frames.inject(0) do |total_score, frame|
      total_score + frame.score
    end
  end
  
  private
  include Parse
  
  def link_to_next(frames)
    frames.each_cons(2) {|current_frame, next_frame| current_frame.next_frame = next_frame}
  end
end