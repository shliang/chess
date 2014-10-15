# encoding: utf-8


require 'debugger'
require 'colorize'

require_relative 'piece'
require_relative 'slidingpiece'
require_relative 'steppingpiece'
require_relative 'pawn'


class Board
  attr_accessor :board, :test_board
  def initialize
    @board = Array.new(8) { Array.new(8) { nil } }
    board_setup
  end
  

  def move(start, end_pos)
    piece = @board[ start[0] ][ start[1] ]
    raise InvalidMoveError.new("No piece at start") if piece.nil?
    raise InvalidMoveError.new("Not a valid move.") unless valid_move?(start, end_pos)
      
    @board[ end_pos[0] ][ end_pos[1] ] = piece
    @board[ start[0] ][ start[1] ] = nil
    piece.position = end_pos
  end
    
  
  
  def checkmate?(color)
    return false unless in_check?(color)
    return false if friendly_pieces(color).any? do |friendly_piece|
      friendly_piece.moves.any? do |move|
        valid_move?(friendly_piece.position, move)
      end
    end
    true
  end
    
  
  def display
    display_string = "  1 2 3 4 5 6 7 8\n"
    @board.each_with_index do |row, index|
      display_string << "#{index + 1} "
      row.each_with_index do |square, index2|
        if index.odd?
          index2.odd? ? bg_color = :light_black : bg_color = :light_white
        else
          index2.odd? ? bg_color = :light_white : bg_color = :light_black
        end
        if square.nil?
          display_string << "  ".colorize(:background => bg_color)
        else
          display_string << (display_square(square) + " ").colorize(:background => bg_color)
        end
      end
      display_string << "\n"
    end
    puts display_string
  end
  
  
  def over?
    checkmate?(:black) || checkmate?(:white) || stalemate?(:black) || stalemate?(:white) 
  end
  
  def stalemate?(color)
    return false if in_check?(color)
    return false if friendly_pieces(color).any? do |friendly_piece|
      friendly_piece.moves.any? do |move|
        valid_move?(friendly_piece.position, move)
      end
    end
    true
  end
  
  def in_check?(color)
    king_position = find_king(color)
    enemy_pieces(color).any? do |enemy_piece|
      valid_move?(enemy_piece.position, king_position)
    end
  end
  
  def valid_move?(start, end_pos)
    piece = @board[ start[0] ][ start[1] ]
    dest_piece = @board[ end_pos[0] ] [ end_pos[1] ]
      
    unless dest_piece.nil?
      return false if @board[ end_pos[0] ] [ end_pos[1] ].color == piece.color
    end
      
    return false unless piece.moves.include?(end_pos)
      
    if piece.is_a?(Pawn)
      return false unless valid_pawn_move?(start, end_pos)
    end
      
    if piece.is_a?(SlidingPiece)
      return false unless valid_sliding_move?(start, end_pos)
    end
    
    return false if moved_into_check?(start, end_pos)
    
    true
  end
  
  private
  
  def display_square(square)
    square.display
  end
  
  def board_setup
    place_pieces
    set_piece_positions
  end
  
  def place_pieces
    @board[1].map! do |square|
      square = Pawn.new(self, nil, :black)
    end
    
    @board[6].map! do |square|
      square = Pawn.new(self, nil, :white)
    end
      
    @board[0][0] = Rook.new(self, nil, :black)
    @board[0][1] = Knight.new(self, nil, :black)
    @board[0][2] = Bishop.new(self, nil, :black)
    @board[0][3] = Queen.new(self, nil, :black)
    @board[0][4] = King.new(self, nil, :black)
    @board[0][5] = Bishop.new(self, nil, :black)
    @board[0][6] = Knight.new(self, nil, :black)
    @board[0][7] = Rook.new(self, nil, :black)
    
    @board[7][0] = Rook.new(self, nil, :white)
    @board[7][1] = Knight.new(self, nil, :white)
    @board[7][2] = Bishop.new(self, nil, :white)
    @board[7][3] = Queen.new(self, nil, :white)
    @board[7][4] = King.new(self, nil, :white)
    @board[7][5] = Bishop.new(self, nil, :white)
    @board[7][6] = Knight.new(self, nil, :white)
    @board[7][7] = Rook.new(self, nil, :white)
  end
  
  def set_piece_positions
    @board.each_with_index do |row, y|
      row.each_with_index do |col, x|
        @board[y][x].position = [y, x] unless @board[y][x].nil?
      end
    end
  end
  
  def move!(start, end_pos)
    test_board = dup
    piece = test_board.board[ start[0] ][ start[1] ]
    raise "No piece at start" if piece.nil?
    test_board.board[ end_pos[0] ][ end_pos[1] ] = piece
    test_board.board[ start[0] ][ start[1] ] = nil
    piece.position = end_pos
    test_board
  end
    
  
  def moved_into_check?(start, end_pos)
    piece = @board[ start[0] ][ start[1] ]
    return true if move!(start, end_pos).in_check?(piece.color)
    false
  end
    
  def valid_pawn_move?(start, end_pos)
    piece = @board[ start[0] ][ start[1] ]
    in_front_piece = @board[ start[0] + 1 ][ start[1] ] if piece.color == :black
    in_front_piece = @board[ start[0] - 1 ][ start[1] ] if piece.color == :white
    dest_piece = @board[ end_pos[0] ] [ end_pos[1] ]
    test_moves = piece.moves
    if end_pos == test_moves.first
      return false unless dest_piece.nil?
    elsif end_pos == test_moves.last
      return false unless dest_piece.nil? && in_front_piece.nil? && hasnt_moved?(piece)
    elsif test_moves[1,2].include?(end_pos)
      return false if dest_piece.nil?
    end
    true
  end
  
  def hasnt_moved?(piece)
    if piece.color == :black
      return piece.position[0] == 1
    elsif piece.color == :white
      return piece.position[0] == 6
    end
  end
    
  def valid_sliding_move?(start, end_pos)
    piece = @board[ start[0] ][ start[1] ]
    dest_piece = @board[ end_pos[0] ] [ end_pos[1] ]
    piece.move_directions.each do |vector|
      ray = piece.follow_path(vector)
      next unless ray.include?(end_pos)
      squares_between = ray[ 0, ray.index(end_pos) - 1 ]
      next unless squares_between
      return false unless squares_between.all? do |square|
        @board[ square[0] ][ square[1] ].nil?
      end
    end
    true
  end
  
  def dup
    dup_board = Board.new
    dup_board.board = []

    @board.each do |row|
      row_board = []
      row.each do |square|
        if square
          dup_piece = square.class.new(dup_board, square.position.dup, square.color)
          row_board << dup_piece
        else
          row_board << nil
        end
      end
      dup_board.board << row_board
    end 
    dup_board
  end
    
  def find_king(color)
    @board.each do |row|
      row.each do |square|
        if square.is_a?(King) && square.color == color
          return square.position
        end
      end
    end
  end
      
  def enemy_pieces(color)
    enemies = []
    @board.each do |row|
      row.each do |square|
        enemies << square if !square.nil? && square.color != color
      end
    end
    enemies
  end
  
  def friendly_pieces(color)
    friendlies = []
    @board.each do |row|
      row.each do |square|
        friendlies << square if !square.nil? && square.color == color
      end
    end
    friendlies
  end
  
end

class InvalidMoveError < StandardError
end