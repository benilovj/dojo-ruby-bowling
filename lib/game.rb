module Parse
  def parse(score_line)
    rolls = score_line.chars.map {|char| Roll.new(char)}
    rolls.each_cons(2) do |roll, next_roll|
      next_roll.previous = roll
      roll.next = next_roll
    end

    frames = []
    until rolls.empty?
      frames << pop_frame(rolls, frames.size == 9)
    end
    frames
  end
  
  def pop_frame(rolls, is_last)
    return ExtendedLastFrame.new((rolls.shift 3).first) if is_last and rolls.size == 3

    first_roll = rolls.shift
    return StrikeFrame.new(first_roll) if first_roll.strike?

    second_roll = rolls.shift
    first_roll.next = second_roll
    return SpareFrame.new(first_roll) if second_roll.spare?
    
    Frame.new(first_roll)
  end  
end

class Roll
  attr_writer :previous
  attr_accessor :next
  def initialize(char)
    @char = char
  end
  
  def strike?
    @char == 'X'
  end
  
  def spare?
    @char == "/"
  end
  
  def gutter?
    @char == "-"
  end
  
  def score
    case @char
    when gutter? then 0
    when strike? then 10
    when spare? then 10 - @previous.score
    else @char.to_i
    end
  end
end

class Frame
  def initialize(first_roll)
    @first_roll = first_roll
  end
  
  def score
    @first_roll.score + @first_roll.next.score
  end
end

class SpareFrame 
  def initialize(first_roll)
    @first_roll = first_roll
  end
  
  def score
    @first_roll.score + @first_roll.next.score + @first_roll.next.next.score
  end
end

class StrikeFrame
  def initialize(first_roll)
    @first_roll = first_roll
  end
  
  def score
    @first_roll.score + @first_roll.next.score + @first_roll.next.next.score
  end  
end

class ExtendedLastFrame
  def initialize(first_roll)
    @first_roll = first_roll
  end
  
  def score
    [@first_roll, @first_roll.next, @first_roll.next.next].map(&:score).inject(:+)
  end
end

class Game
  def score(score_line)
    frames = parse(score_line)
    frames.inject(0) do |total_score, frame|
      total_score + frame.score
    end
  end
  
  private
  include Parse
end