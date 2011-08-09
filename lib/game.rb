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
    return StrikeOrSpareFrame.new((rolls.shift 3).first) if is_last and rolls.size == 3

    first_roll = rolls.shift
    return StrikeOrSpareFrame.new(first_roll) if first_roll.strike?

    second_roll = rolls.shift
    return StrikeOrSpareFrame.new(first_roll) if second_roll.spare?
    
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
    case
    when gutter? then 0
    when strike? then 10
    when spare? then 10 - @previous.score
    else @char.to_i
    end
  end
  
  def and_the_next(number)
    return [self] if number == 0
    return [self] + self.next.and_the_next(number-1)
  end
end

class AbstractFrame
  def initialize(first_roll)
    @first_roll = first_roll
  end

  protected
  def sum_of(rolls)
    rolls.map(&:score).inject(:+)
  end
end

class Frame < AbstractFrame
  def score
    sum_of(@first_roll.and_the_next(1))
  end
end

class StrikeOrSpareFrame < AbstractFrame
  def score
    sum_of(@first_roll.and_the_next(2))
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