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
    
    # Update board
    if possible_moves.include?(end_pos)
      @board[@pos] = nil
      @pos = end_pos
      @board[end_pos] = self
      
      # Promote pawn to king if end_pos is at opposite row
      self.maybe_promote(end_pos)
      return true
    end
    
    return false
  end
  
  def perform_jump(end_pos)
    possible_moves = []
    self.move_dirs.each do |delta_x, delta_y|
      next_pos = [@pos[0] + delta_x*2, @pos[1] + delta_y*2]
      mid_pos = [@pos[0] + delta_x, @pos[1] + delta_y]

      next unless inbound?(next_pos)
      
      # Check if ending position is empty and if piece to jump over is opponent's piece
      if @board[next_pos].nil? and !@board[mid_pos].nil? and @board[mid_pos].color != @color
        possible_moves << [next_pos, mid_pos]
      end
    end
    
    # Update board
    possible_moves.each do |moves|
      if moves[0] == end_pos
        @board[@pos] = nil
        @pos = end_pos
        @board[moves[1]] = nil
        @board[end_pos] = self
      
        # Promote pawn to king if end_pos is at opposite row
        self.maybe_promote(end_pos)
        return true
      end
    end
    
    return false
  end
  
  def all_possible_moves
    possible_moves = []
    
    self.move_dirs.each do |delta_x, delta_y|
      # Sliding possibilities
      next_pos = [@pos[0] + delta_x, @pos[1] + delta_y]
      next unless inbound?(next_pos)
      possible_moves << next_pos if @board[next_pos].nil?
    
      # Jumping possibilities
      next_pos = [@pos[0] + delta_x*2, @pos[1] + delta_y*2]
      mid_pos = [@pos[0] + delta_x, @pos[1] + delta_y]

      next unless inbound?(next_pos)
      
      # Check if ending position is empty and if piece to jump over is opponent's piece
      if @board[next_pos].nil? and !@board[mid_pos].nil? and @board[mid_pos].color != @color
        possible_moves << [next_pos, mid_pos]
      end
    end
    
    possible_moves
  end
  
  def perform_moves(move_seq)
    if valid_moves?(move_seq)
      perform_moves!(move_seq)
    else
      raise InvalidMoveError
    end
  end
  
  def perform_moves!(move_seq)
    if move_seq.length == 1
      return true if perform_slide(move_seq[0])
      return true if perform_jump(move_seq[0])
      return false
    end
    
    # If multiple moves long
    move_seq.each do |end_pos|
      return false if !perform_jump(end_pos)
    end
    
    return true
  end
  
  def valid_moves?(move_seq)
    duped_board = @board.dup
    return duped_board[@pos].perform_moves!(move_seq)
  end
  
  def maybe_promote(end_pos)
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
  
  def inbound?(pos)
    pos[0].between?(0,7) and pos[1].between?(0,7)
  end
  
  def dup
    Piece.new(@color, @pos.dup, @board, @type)
  end
end