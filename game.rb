require_relative 'board'

class WrongColorError < StandardError
end

class NoPieceError < StandardError
end

class Game

  def self.human_v_human
    Game.new(wht: HumanPlayer.new(:wht), red: HumanPlayer.new(:red))
  end

  def self.comp_v_comp
    Game.new(wht: ComputerPlayer.new(:wht), red: ComputerPlayer.new(:red))
  end

  attr_accessor :players, :board

  def initialize(players)
    @players = players
    @board = Board.new
    players.each {|color, player| player.board = @board if player.is_a?(ComputerPlayer)}
  end

  def color_valid?(piece, color)
    piece.color == color
  end

  def play
    puts "Welcome to Checkers."
    turn = :wht

    until board.lost?(turn)
      system("clear")
      board.render
      begin
        start, destination = players[turn].play_turn
        #byebug
        raise NoPieceError.new if board[start].nil?
        raise WrongColorError unless color_valid?(board[start], turn)
        self.board.move_piece(start, destination)
      rescue NoPieceError => e
        puts "There's no piece there." if players[turn].is_a?(HumanPlayer)
        retry
      rescue WrongColorError => e
        puts "Choose a piece of your own color." if players[turn].is_a?(HumanPlayer)
        retry
      rescue BoardEdgeError
        puts "You can't move off the board!" if players[turn].is_a?(HumanPlayer)
        retry
      rescue InvalidMoveError
        puts "You tried to move to #{destination}, which is invalid." if players[turn].is_a?(HumanPlayer)
        retry
      rescue NoMethodError
        puts "idk lol" if players[turn].is_a?(HumanPlayer)
        retry
      end

      sleep(0.1) if players[turn].is_a?(ComputerPlayer)
      turn = (turn == :wht) ? :red : :wht

    end

    puts "#{(board.lost?(:wht)) ? "Red" : "White"} wins!"

  end

end

class Player

  attr_accessor :color

  def initialize(color)
    @color = color
  end

  def play_turn
  end

end

class HumanPlayer < Player

  def play_turn
    puts "#{(color == :wht) ? "White" : "Red"}, choose start and end coordinates."
    gets.chomp.split(" ").map { |pos| ["abcdefgh".split("").find_index(pos[0]), pos[1].to_i] }
  end

end

class ComputerPlayer < Player

  attr_accessor :board

  def initialize(color, board = nil)
    super(color)
  end

  def play_turn
    play_random
  end

  private

    def play_random
      piece = board.color_pieces(color).sample
      destination = (piece.sliding_moves + piece.jumping_moves).sample
      [piece.pos, destination]
    end

end


#g = Game.human_v_human
#g = Game.comp_v_comp
g = Game.new(wht: ComputerPlayer.new(:wht), red: HumanPlayer.new(:red))
g.play
