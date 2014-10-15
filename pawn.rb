# encoding: utf-8

class Pawn < Piece
  
  def initialize(board, position, color)
    @board, @position, @color = board, position, color
  end
  
  def moves
    in_bounds_moves = []
    vectors.each do |vector|
      test_position = add_vector(@position, vector)
      in_bounds_moves << test_position if in_bounds?(test_position)
    end
    in_bounds_moves
  end
  
  def vectors
    return [ [-1, 0], [-1, -1], [-1, 1], [-2, 0] ] if @color == :white
    return [ [1, 0], [1, -1], [1, 1], [2, 0] ] if @color == :black
  end
  
  def display
    return "♙" if @color == :white
    return "♟" if @color == :black
  end
end