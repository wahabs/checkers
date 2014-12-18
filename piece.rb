class Piece

  def attr_accessor :board, :color, :pos, :kinged

  def initialize(board, color, pos, kinged = false)
    @board = board
    @color = color
    @pos = pos
    @kinged = kinged
  end

  def perform_slide(destination)
    unless board[destination].nil? && sliding_moves.include?(destination)
      return false
    end
    board[destination] = self
    board[pos] = nil
    pos = destination
    maybe_promote
    true
  end

  def perform_jump(enemy, destination)

    unless board[destination].nil? && enemy.color != color && sliding_moves.include?(enemy.pos)
      return false
    end

    board[enemy.pos] = nil
    perform_slide[enemy.pos]
    perform_slide[destination]

    maybe_promote
    true
  end


  private

    def sliding_moves
      move_diffs.map { |diff| [pos[0] + diff[0], pos[1] + diff[1]] }
    end

    def move_diffs
      (kinged) ? [[1,1], [-1,1]] : [[1,1], [-1,1], [1,-1], [-1, -1]]
    end

    def king_me
      kinged = true
    end

    def maybe_promote
      back_row = (color == :black) ? 7 : 0
      king_me if pos[0] == back_row
    end

end
