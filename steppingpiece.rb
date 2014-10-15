# encoding: utf-8

class SteppingPiece < Piece
  def moves
    in_bounds_moves = []
    move_vectors.each do |vector|
      test_position = add_vector(@position, vector)
      in_bounds_moves << test_position if in_bounds?(test_position)
    end
    
    in_bounds_moves
  end
end

class Knight < SteppingPiece
  def move_vectors
    [[-2, -1], [-1, -2], [-2, 1], [-1, 2], [1, 2], [1, -2], [2, 1], [2, -1]]
  end
  
  def display
    return "♘" if @color == :white
    return "♞" if @color == :black
  end
end

class King < SteppingPiece
  def move_vectors
    [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, 1], [1, 0], [1, -1]]
  end
  
  def display
    return "♔" if @color == :white
    return "♚" if @color == :black
  end
end
  