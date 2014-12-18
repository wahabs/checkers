require 'colorize'

class InvalidMoveError < StandardError
end

class Piece

  attr_accessor :board, :color, :pos, :kinged

  def initialize(board, color, pos, kinged = false)
    @board = board
    @color = color
    @pos = pos
    @kinged = kinged
  end

  def perform_moves(sequence)
    if valid_mov_seq?(sequence)
      perform_moves!(sequence)
    else
      raise InvalidMoveError.new
    end
  end

  def perform_slide(destination)
    unless board[destination].nil? && sliding_moves.include?(destination)
      return false
    end
    board[destination] = self
    board[pos] = nil
    self.pos = destination
    maybe_promote
    true
  end

  def perform_jump(enemy, destination)
    unless board[destination].nil? && enemy.color != color && sliding_moves.include?(enemy.pos)
      return false
    end
    board[enemy.pos] = nil
    return false unless perform_slide(enemy.pos)
    perform_slide(destination)
  end

  def adjacent_enemy_positions
    sliding_moves.reject {|adjacent_pos| board[adjacent_pos].nil?}
  end

  def in_valid_direction?(other_pos)
    move_diffs.include?([other_pos[0] - pos[0], other_pos[1] - pos[1]])
  end

  def render
    shape = (kinged) ? " ◈" : " ◉"
    (color == :wht) ? shape.colorize(:white) : shape.colorize(:red)
  end

  def inspect
    {color: color, pos: pos, kinged: kinged}
  end


  private

    def sliding_moves
      move_diffs.map { |diff| [pos[0] + diff[0], pos[1] + diff[1]] }
    end

    def move_diffs
      return [[1,1], [-1,1], [1,-1], [-1, -1]] if kinged
      color == :wht ? [[1, 1], [1, -1]] : [[-1, 1], [-1, -1]]
    end

    def maybe_promote
      back_row = (color == :wht) ? 7 : 0
      self.kinged = true if pos[0] == back_row
    end

    def valid_mov_seq?(sequence)
      true
    end

    def perform_moves!(sequence)
      sequence.each {|destination| board.move_piece(pos, destination)}
    end

end
