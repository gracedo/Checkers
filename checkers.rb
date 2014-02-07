# coding: utf-8

require './piece'
require './board'

class InvalidMoveError < StandardError
  attr_reader :message

  def initialize
    @message = "invalid move!"
  end
end

class Game
  def initialize
    @board = Board.new
    @player1 = HumanPlayer.new(:black, @board)
    @player2 = HumanPlayer.new(:white, @board)
    @curr_player = @player1
    self.play
  end
  
  def play
    @board.show_board
    puts "#{@curr_player.name}'s turn"
    puts "Please select a piece (its location on the board, e.g. 0,0):"
    start_pos = gets.chomp!.split(',')
    start_pos = [start_pos[0].to_i, start_pos[1].to_i]
    start_piece = @board[start_pos]
    
    puts "Please select destination (e.g. 1,1):"
    end_pos = gets.chomp!.split(',')
    end_pos = [end_pos[0].to_i, end_pos[1].to_i]
    
    p start_pos
    p end_pos
    
    #until game is over
    #play game
    #at end of turn/loop, switch current player
  end
  
  def game_over?
    #no more pieces of one color left or no more moves remaining
    
  end
end

class Player
  attr_reader :color
  
  def initialize(color, board)
    @color = color
    @board = board
  end
end

class HumanPlayer < Player
  attr_reader :name
  
  def initialize(color, board)
    super
    @name = get_name
  end
  
  def get_name
    puts "Enter player name:"
    return gets.chomp!
  end
end

# b = Board.new

g = Game.new

# w = Piece.new(:white, [0,0], b)
# b1 = Piece.new(:black, [1, 1], b)
# b2 = Piece.new(:black, [3,3], b)
# b3 = Piece.new(:black, [5,5], b)
# b[[0,0]] = w
# b[[1,1]] = b1
# b[[3,3]] = b2
# b[[5,5]] = b3
# b.show_board
# 
# w.perform_moves([[2,2],[4,4],[6,6]])
# b.show_board

# p2.perform_slide([1,5])
# b.show_board

# pb.perform_jump([2,2])
# b.show_board

# pk.perform_slide([7,4])
# b.show_board


