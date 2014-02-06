# coding: utf-8

class InvalidMoveError < StandardError
  attr_reader :message

  def initialize
    @message = "invalid move!"
  end
end

class Game
  def initialize
  end
end

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
          self[[i, j]] = Piece.new(:black, [i,j], self) if j % 2 == n
        end
      end
      n = (n == 0 ? 1 : 0)
    end
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
  
  def []=(pos, piece)
    @board[pos[0]][pos[1]] = piece
  end

  def [](pos)
    @board[pos[0]][pos[1]]
  end
end


class Piece
  attr_reader :color, :pos, :type, :icon
  attr_writer :board
  
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
      raise InvalidMoveError
      return false
    end
    
    true
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
        raise InvalidMoveError
        return false
      end
    end
    
    true
  end
  
  def perform_moves(move_seq)
    if valid_moves?(move_seq)
      perform_moves!(move_seq)
    else
      raise InvalidMoveError
    end
    
    true
  end
  
  def perform_moves!(move_seq)
    #run loop of all moves as wrapper for valid moves?
    if move_seq.length == 1
      if perform_slide(move_seq[0])
        return true
      elsif perform_jump(move_seq[0])
        return true
      else
        raise InvalidMoveError
        return false
      end
    end
    
    # if multiple moves long
    move_seq.each do |end_pos|
      unless perform_jump(end_pos)
        raise InvalidMoveError
        return false
      end
    end
    
    true
  end
  
  def valid_moves?(move_seq)
    duped_board = @board.dup
    
    return duped_board[@pos].perform_moves!(end_pos, duped_board)
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
    Piece.new(@color, @pos.dup, @board, @type)
  end
end

b = Board.new

# pb = Piece.new(:white, [0,4], b)
# p = Piece.new(:black, [1, 3], b)
# p2 = Piece.new(:white, [0, 6], b)
# pk = Piece.new(:white, [6,5], b)
# b[[0,4]] = pb
# b[[1,3]] = p
# b[[0,6]] = p2
# b[[6,5]] = pk
b.show_board

# p2.perform_slide([1,5])
# b.show_board

# pb.perform_jump([2,2])
# b.show_board

# pk.perform_slide([7,4])
# b.show_board


