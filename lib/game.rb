module Parse
  def parse(score_line)
    score_chars = score_line.chars.to_a
    frames = []
    until score_chars.empty?
      if frames.size == 9 and (score_chars[0] == "X" or score_chars[1] == "/")
        frame = ExtendedLastFrame.new(*score_chars)
        score_chars = []
      else
        first_roll = score_chars.shift
        frame = case first_roll
                when 'X' then Frame.new(first_roll, nil)
                else Frame.new(first_roll, score_chars.shift)
                end
      end
      frames << frame
    end
    frames
  end
end

class Frame
  attr_writer :next_frame
  
  def initialize(first_roll, second_roll = nil)
    @first_roll = first_roll
    @second_roll = second_roll
  end
  
  def score
    if strike_frame?
      10 + @next_frame.score_of_next_two_rolls
    elsif spare_frame?
      10 + @next_frame.score_of_first_roll
    else
      @first_roll.to_i + @second_roll.to_i
    end
  end
  
  def score_of_first_roll
    if strike_frame?
      10
    else
      @first_roll.to_i
    end
  end
  
  def score_of_next_two_rolls
    if strike_frame?
      10 + @next_frame.score_of_first_roll
    elsif spare_frame?
      10
    else
      @first_roll.to_i + @second_roll.to_i
    end
  end
  
  protected
  def strike_frame?
    @first_roll == "X"
  end
  
  def spare_frame?
    @second_roll == "/"
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