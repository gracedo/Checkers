# coding: utf-8

require './piece'
require './board'

class InvalidMoveError < StandardError
  attr_reader :message

  def initialize
    @message = "Error: invalid move!"
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
    
    until game_over?
      begin
        puts "#{@curr_player.name}'s turn"
        puts "Please select a piece (its location on the board, e.g. 00 for [0,0]):"
        start_pos = gets.chomp!.split('')
        start_pos = [start_pos[0].to_i, start_pos[1].to_i]
        start_piece = @board[start_pos]
        
        raise InvalidMoveError if start_piece.nil?
        raise InvalidMoveError if start_piece.color != @curr_player.color
  
        puts "Please select your destination(s) (e.g. 11,22 for [1,1],[2,2]):"
        end_pos = gets.chomp!.split(',')
        end_pos.map! do |pos|
          [pos[0].to_i, pos[1].to_i]
        end
        
        start_piece.perform_moves(end_pos) # Play the move
    
        @board.show_board
        @curr_player = (@curr_player == @player1 ? @player2 : @player1 )
      rescue InvalidMoveError => e
        puts e.message
      end
    end
    
    if !@board.pieces_left?(@curr_player.color)
      winner = (@curr_player == @player1 ? @player2 : @player1 )
      puts "Game over!! No more moves for #{@curr_player.name}."
      puts "The winner is #{winner}!!"
    else
      puts "Stalemate game, no moves remaining."
    end
  end
  
  def game_over?
    !@board.pieces_left?(@curr_player.color) || !@board.moves_left?(@curr_player.color)
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

 g = Game.new