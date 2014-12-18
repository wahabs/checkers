require 'colorize'
require_relative 'piece'

class NoPieceError < StandardError
end

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
    raise NoPieceError.new if piece.nil?
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
    puts "\n\n   0 1 2 3 4 5 6 7".colorize(:blue)
    (0..7).each do |row|
      print " #{row}".colorize(:blue)
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

  # def dup
  #   board_clone = Board.new(true)
  #   (0..7).each do |row|
  #     (0..7).each do |col|
  #     end
  #   end
  # end

  private

  def traverse(&prc)
    prc ||= Proc.new {|row, col| puts "(#{row},#{col})"}
    (0..7).each do |row|
      (0..7).each do |col|
        prc.call(row, col)
      end
    end
  end

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

b = Board.new
b.render
#b.move_piece([5,0], [4,1])
# b.move_piece([2,3], [3,2])
# b[[5,2]].perform_moves([[4,1], [2,3]])
# b.move_piece([4,1], [2,3])
# b.move_piece([1,4], [3,2])
# b.move_piece([0,5], [1,4])
# b.move_piece([5,4], [4,5])
# b.move_piece([4,5], [3,4])
# b.move_piece([3,4], [2,3])
# b.move_piece([2,3], [0,5])
# b.move_piece([0,5], [1,4])
# b.move_piece([1,4], [2,3])
# b.move_piece([2,3], [4,1])
# b.move_piece([2,7], [3,8])
#
