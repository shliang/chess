# encoding: utf-8

class Piece
  attr_accessor :board, :position, :color
  def initialize(board, position, color)
    @board = board
    @position = position
    @color = color
  end
  
  
  def moves
    
  end
  
  def add_vector(position, vector)
    [ ( position[0] + vector[0] ) , ( position[1] + vector[1] ) ]
  end
  
  def in_bounds?(position)
    position.all? {|coord| (0..7).include?(coord)}
  end
  
  def inspect
    return "#{self.color} #{self.class} @ #{self.position}"
  end
  
  def display
  end
end