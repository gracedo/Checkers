require 'colorize'

class Board
  attr_accessor :board
  
  def initialize
    @board = Array.new(8) { Array.new(8) }
    init_board
  end
  
  def init_board
    n = 0
    
    @board.each_with_index do |row, i|
      next if i > 2 and i < 5
      row.each_with_index do |col, j|
        if i < 3
          self[[i, j]] = Piece.new(:white, [i,j], self) if j % 2 != n
        elsif i > 4
          self[[i, j]] = Piece.new(:black, [i,j], self) if j % 2 != n
        end
      end
      n = (n == 0 ? 1 : 0) # for alternating locations
    end
  end
  
  def show_board
    white = false
    puts "   0  1  2  3  4  5  6  7"
    @board.each_with_index do |row, i|
      print "#{i} "
      row.each_with_index do |col, j|
        if white
          col.nil? ? print("   ".on_green) : print(" #{col.icon} ".on_green)
          white = !white
        else
          col.nil? ? print("   ") : print(" #{col.icon} ")
          white = !white
        end
      end
      white = !white
      puts " #{i}"
    end
    puts "   0  1  2  3  4  5  6  7"
  end
  
  def dup
    board_copy = Board.new
    
    @board.each_with_index do |row, i|
      row.each_with_index do |piece, j|
        unless piece.nil?
          board_copy[[i, j]] = piece.dup
          board_copy[[i, j]].board = board_copy
        else
          board_copy[[i, j]] = nil
        end
      end
    end
    
    board_copy
  end
  
  def get_pieces(color)
    pieces = []
    
    @board.each_with_index do |row, i|
      row.each_with_index do |tile, j|
        unless tile.nil?
          pieces << tile if tile.color == color
        end
      end
    end
    
    pieces
  end
  
  def pieces_left?(color)
    !get_pieces(color).empty?
  end
  
  def moves_left?(color)
    get_pieces(color).each do |piece|
      return true if !piece.all_possible_moves.empty?
    end
    
    false
  end
  
  def []=(pos, piece)
    @board[pos[0]][pos[1]] = piece
  end

  def [](pos)
    @board[pos[0]][pos[1]]
  end
end
