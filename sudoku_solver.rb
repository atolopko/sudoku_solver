require 'Set'

class Cell

  attr_reader :row, :col
  
  def initialize(row, col, grid)
    @row = row
    @col = col
    @grid = grid
    @candidates = (1..9).to_set
  end

  def solved?
    @candidates.size == 1
  end

  def solve(value)
    (1..9).to_set.delete(value).each { |candidate| eliminate(candidate) }
  end

  def eliminate(candidate)
    unless solved?
      @candidates.delete(candidate)
      #puts "eliminated #{candidate} from #{[@row,@col]}"
      if solved?
        #puts "solved #{self}"
        @grid.update_row(@row, value)
        @grid.update_col(@col, value)
        @grid.update_box(@row, @col, value)
      end
    end
  end

  def value
    @candidates.first if solved?
  end

  def ==(other)
    @row == other.row && @col == other.col
  end

  def to_s
    "(#{row},#{col})={#{@candidates.entries.join(',')}}"
  end
end

class Grid
  attr_reader :g

  def initialize
    @g = (0..8).map { |row| (0..8).map { |col| Cell.new(row, col, self) } }
  end

  def solve(initial)
    (0..8).each do |row| 
      (0..8).each do |col|
        value = initial[row][col].to_i
        g[row][col].solve(value) if (1..9).include?(value)
      end
    end
    # TODO: verify completely solved
    self
  end

  def [](row)
    g[row]
  end

  def update_row(row, value)
    g[row].each { |cell| cell.eliminate(value) }
  end

  def update_col(col, value)
    9.times do |row|
      g[row][col].eliminate(value)
    end
  end

  def update_box(row, col, value)
    box(row,col).each { |cell| cell.eliminate(value) }
  end

  def box(row, col)
    box_row = row / 3
    box_col = col / 3
    [g[box_row * 3 + 0][box_col * 3 + 0],
     g[box_row * 3 + 1][box_col * 3 + 0],
     g[box_row * 3 + 2][box_col * 3 + 0],
     g[box_row * 3 + 0][box_col * 3 + 1],
     g[box_row * 3 + 1][box_col * 3 + 1],
     g[box_row * 3 + 2][box_col * 3 + 1],
     g[box_row * 3 + 0][box_col * 3 + 2],
     g[box_row * 3 + 1][box_col * 3 + 2],
     g[box_row * 3 + 2][box_col * 3 + 2]]
  end

  def to_s
    @g.map { |row| row.map { |cell| cell.solved? ? cell.value : '.' }.join('') }.join("\n")
  end
end


["..19..7..",
 "4..83.59.",
 "3.7.54.2.",
 ".495.6...",
 "7.......6",
 "...7.125.",
 ".7.61.4.5",
 ".68.49..2",
 "..4..58.."]
