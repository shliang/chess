# encoding: utf-8

require_relative "board"
require_relative "humanplayer"

class Game
  def initialize(player1, player2)
    @board = Board.new
    @player1, @player2 = player1, player2
  end
  
  def play
    turn = 1
    last_move = nil
    last_piece_moved = nil
    until @board.over?
      @board.display
      turn.odd? ? (current_player = @player1) : (current_player = @player2)
      turn += 1
      moving_path = current_player.user_input
      begin
        last_move = [moving_path[0], moving_path[1]]
        last_piece_moved = @board.board[last_move[0][0]][last_move[0][1]]
        @board.move(moving_path[0], moving_path[1])
      rescue InvalidMoveError => e
        @board.display
        puts e.message
        moving_path = current_player.user_input
        retry
      end
    end
    
    @board.board[last_move[1][0]][last_move[1][1]] = last_piece_moved
    @board.display
    
    if @board.stalemate?(:white) || @board.stalemate?(:black)
      puts "Draw game!"
    else
      (turn.even?) ? puts("White wins") : puts("Black wins")
    end
  end
end

if $PROGRAM_NAME == __FILE__
  g = Game.new(HumanPlayer.new, HumanPlayer.new)
  g.play
end