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

  def perform_moves(*sequence)
    if valid_mov_seq?(sequence)
      perform_moves!(sequence)
    else
      raise InvalidMoveError.new
    end
  end

  def perform_moves!(sequence)
    sequence.each {|destination| board.move_piece(pos, destination)}
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
    unless board[destination].nil? && enemy.color != color && jumping_moves.include?(destination)
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
    slide_diffs.include?([other_pos[0] - pos[0], other_pos[1] - pos[1]])
  end

  def render
    shape = (kinged) ? " ◈" : " ◉"
    (color == :wht) ? shape.colorize(:white) : shape.colorize(:red)
  end

  def inspect
    {color: color, pos: pos, kinged: kinged}
  end

  def sliding_moves
    slide_diffs.map { |diff| [pos[0] + diff[0], pos[1] + diff[1]] }
  end

  def jumping_moves
    slide_diffs.map { |diff| [pos[0] + diff[0]*2, pos[1] + diff[1]*2] }
  end

    private

    def slide_diffs
      return [[1,1], [-1,1], [1,-1], [-1, -1]] if kinged
      color == :wht ? [[1, 1], [1, -1]] : [[-1, 1], [-1, -1]]
    end

    def maybe_promote
      back_row = (color == :wht) ? 7 : 0
      self.kinged = true if pos[0] == back_row
    end

    def valid_mov_seq?(sequence)
      begin
        board_clone = board.dup
        board_clone[pos].perform_moves!(sequence)
        true
      rescue InvalidMoveError
        false
      end
    end

end
