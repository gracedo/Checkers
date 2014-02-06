# coding: utf-8

class Game
  def initialize
  end
end

class Board
  def initialize
    @board = Array.new(8) { Array.new(8) }
    init_board
  end
  
  def init_board
    #
  end
  
  def show_board
    puts "   0  1  2  3  4  5  6  7"
    @board.each_with_index do |row, i|
      print "#{i} "
      row.each_with_index do |col, j|
        col.nil? ? print(" _ ") : print(" #{col.icon} ")
      end
      puts " #{i}"
    end
    puts "   0  1  2  3  4  5  6  7"
  end
  
  def dup
  end
  
  def []=(pos, piece)
    @board[pos[0]][pos[1]] = piece
  end

  def [](pos)
    @board[pos[0]][pos[1]]
  end
end


class Piece
  attr_reader :color, :pos, :type, :icon
  
  def initialize(color, pos, board, type = :pawn)
    @color = color
    @pos = pos
    @board = board
    @type = type
    icon
    move_dirs
  end
  
  # if decide to only call this in initialize, then refactor, remove pawn condition
  def move_dirs
    if @type == :pawn and @color == :white
      return [[1, 1], [1, -1]]
    elsif @type == :pawn and @color == :black
      return [[-1, -1], [-1, 1]]
    elsif @type == :king
      return [[1, 1], [1, -1], [-1, -1], [-1, 1]]
    end
  end
  
  def icon
    if @color == :white
      return '○' if @type == :pawn
      return '△' if @type == :king
    elsif @color == :black
      return '●' if @type == :pawn
      return '▲' if @type == :king
    end
  end
  
  def perform_slide(end_pos)
    # move forward diagonally, two possible directions if pawn

    possible_moves = []
    self.move_dirs.each do |delta_x, delta_y|
      next_pos = [@pos[0] + delta_x, @pos[1] + delta_y]
      next unless inbound?(next_pos)
      
      possible_moves << next_pos if @board[next_pos].nil?
    end
      
    if possible_moves.include?(end_pos)
      # update pos and board state
      @board[@pos] = nil
      @pos = end_pos
      @board[end_pos] = self
      
      # promote pawn to king if end_pos is at opposite row
      self.maybe_promote(end_pos)
      return
    else
      #raise error: invalid move
    end
  end
  
  def perform_jump(end_pos)
    possible_moves = []
    self.move_dirs.each do |delta_x, delta_y|
      next_pos = [@pos[0] + delta_x*2, @pos[1] + delta_y*2]
      mid_pos = [@pos[0] + delta_x, @pos[1] + delta_y]

      next unless inbound?(next_pos)
      
      # If ending position is empty and the piece to jump over is opponent's piece, it is a valid move
      if @board[next_pos].nil? and !@board[mid_pos].nil? and @board[mid_pos].color != @color #need another nil check, will hit error?
        possible_moves << [next_pos, mid_pos]
      end
    end
    
    possible_moves.each do |moves|
      if moves[0] == end_pos
        # update pos and board state
        @board[@pos] = nil
        @pos = end_pos
        @board[moves[1]] = nil # remove eaten piece
        @board[end_pos] = self
      
        # promote pawn to king if end_pos is at opposite row
        self.maybe_promote(end_pos)
        return
      else
        # raise error: invalid move
      end
    end
  end
  
  def perform_moves(move_seq)
    #run loop of all moves as wrapper for valid moves?
  end
  
  def perform_moves!
  end
  
  def valid_moves?(move_seq)
    possible_moves = []
    
    # @move_dir.each do |delta_x, delta_y|
    #   next_pos = [@pos[0] + delta_x, @pos[1] + delta_y]
    #   possible_moves << next_pos if @board[next_pos].nil
    # end
      
    possible_moves.include?(end_pos)
  end
  
  def maybe_promote(end_pos)
    if @type == :pawn
      if (@color == :black and end_pos[0] == 0)
        @type = :king
        icon
        move_dirs
      elsif (@color == :white and end_pos[0] == 7)
        @type = :king
        icon
        move_dirs
      end
    end
  end
  
  def inbound?(pos)
    pos[0].between?(0,7) and pos[1].between?(0,7)
  end
  
  def dup
  end
end

b = Board.new

pb = Piece.new(:white, [0,4], b)
p = Piece.new(:black, [1, 3], b)
p2 = Piece.new(:white, [0, 6], b)
pk = Piece.new(:white, [6,5], b)
b[[0,4]] = pb
b[[1,3]] = p
b[[0,6]] = p2
b[[6,5]] = pk
b.show_board
puts "-----------------"
puts "PERFORMING SLIDE TO [1,5]"
p2.perform_slide([1,5])
b.show_board
puts "-----------------"
puts "PERFORMING JUMP TO [2,2]"
pb.perform_jump([2,2])
b.show_board
puts "-----------------"
puts "PERFORMING SLIDE AND PROMOTE TO KING TO [7,4]"
pk.perform_slide([7,4])
b.show_board



