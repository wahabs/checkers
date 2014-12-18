require 'piece'

class Board

  attr_accessor :grid

  def initialize
    @grid = Array.new(8) { Array.new(8) }
    fill_board
  end

  def [](pos)
    grid[pos[0], pos[1]]
  end

  def []=(pos, piece)
    self[pos] = piece
  end

  def render
    self.grid.each do |row|
      self.grid.each do |col|
        print "#{(self[[row, col]].nil?) ? " " : self[[row, col]]}"
      end
      print "\n"
    end
  end

  private

    def fill_board
      (0..7).each do |row|
        (0..7).each { |col| add_piece([row, col]) }
      end
    end

    def add_piece(pos)
      if (pos[0] + pos[1]).odd?
        self[pos] = Piece.new(self, :blk, pos) if pos[0] < 3
        self[pos] = Piece.new(self, :red, pos) if pos[0] > 4
      end
    end

end
