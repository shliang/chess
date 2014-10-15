# encoding: utf-8

class SlidingPiece < Piece
  ORTH = [[1,0], [-1, 0], [0 ,-1 ], [0, 1]]
  DIAG = [[1,1], [1, -1], [-1, 1], [-1, -1]]
  
  def moves
    in_bounds_moves = []

    move_directions.each do |vector|
      new_moves = follow_path(vector)
      in_bounds_moves += new_moves
    end
    
    in_bounds_moves
  end
  
  def follow_path(vector)
    test_position = add_vector(@position, vector)
    move_path = []
    while in_bounds?(test_position)
      move_path << test_position
      test_position = add_vector(test_position, vector)
    end
    move_path
  end
end

class Bishop < SlidingPiece
  def move_directions
    DIAG
  end
  
  def display
    return "♗" if @color == :white
    return "♝" if @color == :black
  end
end

class Rook < SlidingPiece
  def move_directions
    ORTH
  end
  
  def display
    return "♖" if @color == :white
    return "♜" if @color == :black
  end
end

class Queen < SlidingPiece
  def move_directions
    DIAG + ORTH
  end
  
  def display
    return "♕" if @color == :white
    return "♛" if @color == :black
  end
end
