require 'colorize'
require_relative 'piece'

class BoardEdgeError < StandardError
end

class Board

  attr_accessor :grid

  def initialize(start_empty = false)
    @grid = Array.new(8) { Array.new(8) }
    fill_board unless start_empty
  end

  def [](pos)
    grid[pos[0]][pos[1]]
  end

  def []=(pos, piece)
    grid[pos[0]][pos[1]] = piece
  end

  def move_piece(from, destination)

    piece = self[from]
    #raise NoPieceError.new if piece.nil?
    raise BoardEdgeError.new unless destination.all? {|dir| (0..7).cover?(dir)}

    if piece.perform_slide(destination)
      render
    else
      jumping_over = piece.adjacent_enemy_positions.select do |enemy_pos|
        is_diagonal?(enemy_pos, destination)
      end[0]
      #byebug
      if !jumping_over.nil? && piece.perform_jump(self[jumping_over], destination)
        render
      else
        raise InvalidMoveError.new
      end
    end

  end

  def render
    puts "\n   0 1 2 3 4 5 6 7".colorize(:blue)
    (0..7).each do |row|
      print " #{"abcdefgh"[row]}".colorize(:blue)
      (0..7).each do |col|
        if self[[row, col]].nil?
          print " ▢".colorize(:blue)
        else
          print self[[row, col]].render
        end
      end
      print "\n"
    end
    nil
  end

  def dup
    board_clone = Board.new(true)
    board_clone.traverse do |row, col|
      piece = self[[row, col]]
      unless piece.nil?
        board_clone[[row, col]] = Piece.new(board_clone, piece.color, piece.pos, piece.kinged)
      end
    end
    board_clone
  end

  def traverse(&prc)
    prc ||= Proc.new {|row, col| puts "(#{row},#{col})"}
    (0..7).each {  |row| (0..7).each { |col| prc.call(row, col) }  }
  end

  def color_pieces(color)
    grid.flatten.compact.select {|piece| piece.color == color}
  end

  def lost?(color)
    color_pieces(color).empty?
  end

  # def needs_to_jump?(color)
  #   color_pieces(color).any? do |piece|
  #     board_clone = self.dup
  #     piece_clone = board_clone[piece.pos]
  #
  #     piece_clone.adjacent_enemy_positions.each |enemy_pos| do
  #       piece_clone.perform_jump(board_clone[enemy_pos], )
  #     end
  #     #board_clone[piece.pos].perform_jump(,)
  #   end
  # end

  private

    def is_diagonal?(pos, other_pos)
      [[1,1], [-1,1], [1,-1], [-1, -1]].include?([other_pos[0] - pos[0], other_pos[1] - pos[1]])
    end

    def fill_board
      traverse {|row, col| add_piece([row, col])}
    end

    def add_piece(pos)
      if (pos[0] + pos[1]).odd?
        self[pos] = Piece.new(self, :wht, pos) if pos[0] < 3
        self[pos] = Piece.new(self, :red, pos) if pos[0] > 4
      end
    end

end
