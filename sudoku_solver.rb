require 'Set'

class Cell

  attr_reader :row, :col, :candidates
  
  def initialize(row, col, grid)
    @row = row
    @col = col
    @grid = grid
    @candidates = (1..9).to_set
  end
  
  def solved?
    candidates.size == 1
  end
  
  def solve(value)
    unless solved?
      # puts "solving #{self} to #{value}"
      candidates_to_eliminate = (1..9).to_set.delete(value)
      # candidates_to_eliminate.each { |candidate| eliminate(candidate) } # TOOD: infinite recursion!
      candidates.subtract(candidates_to_eliminate)
      candidates_to_eliminate.each do |candidate|
        @grid.test_row_solved_for(row, candidate)
        @grid.test_col_solved_for(col, candidate)
        @grid.test_box_solved_for(row, col, candidate)
      end
      @grid.eliminate_from_related_cells(self)
      true
    end
  end

  def eliminate(candidate)
    unless solved?
      if candidates.delete(candidate)
        # puts "eliminated #{candidate} from #{[@row,@col]}"
        @grid.test_row_solved_for(row, candidate)
        @grid.test_col_solved_for(col, candidate)
        @grid.test_box_solved_for(row, col, candidate)
        if solved?
          # puts "solved #{self} via elimination"
          @grid.eliminate_from_related_cells(self)
        end
      end
    end
  end

  def value
    candidates.first if solved?
  end

  def to_i 
    value
  end

  def ==(other)
    @row == other.row && @col == other.col
  end

  def to_s
    "(#{row},#{col})={#{candidates.entries.join(',')}}"
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
        if (1..9).include?(value)
          # puts "setting #{row},#{col} with #{value}"
          g[row][col].solve(value) 
        end
      end
    end
    self
  end
   
  def solved?
    g.flatten.all?(&:solved?)
  end

  def [](row)
    g[row]
  end

  def column(col)
    (0..8).map { |row| g[row][col] }
  end    

  # if a cell in the row is the only one with the candidate value, it
  # must be that value
  def test_row_solved_for(row, value)
    # puts "test_row_solved_for(#{row}, #{value})"
    cells_with_value =
      g[row].select { |cell| cell.candidates.include?(value) }
    if cells_with_value.size == 1
      # puts "solved #{cells_with_value.first} in row" if
        cells_with_value.first.solve(value)
    end
  end

  # if a cell in the col is the only one with the candidate value, it
  # must be that value
  def test_col_solved_for(col, value)
    # puts "test_col_solved_for(#{col}, #{value})"
    cells_with_value =
      column(col).select { |cell| cell.candidates.include?(value) }
    if cells_with_value.size == 1
      # puts "solved #{cells_with_value.first} in col" if
        cells_with_value.first.solve(value)
    end
  end
     
  # if a cell in the box is the only one with the candidate value, it
  # must be that value
  def test_box_solved_for(row, col, value)
    # puts "test_box_solved_for(#{row}, #{col}, #{value})"
    cells_with_value =
      box(row, col).select { |cell| cell.candidates.include?(value) }
    if cells_with_value.size == 1
      # puts "solved #{cells_with_value.first} in box" if
        cells_with_value.first.solve(value)
    end
  end

  def eliminate_from_related_cells(solved_cell)
    (row(solved_cell.row) + 
     col(solved_cell.col) + 
     box(solved_cell.row, solved_cell.col)).
      to_set.
      delete(solved_cell).
      each { |cell| cell.eliminate(solved_cell.value) }
  end

  def row(row)
    g[row]
  end

  def col(col)
    (0..8).map { |row| g[row][col] }
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

# ["..19..7..",
#  "4..83.59.",
#  "3.7.54.2.",
#  ".495.6...",
#  "7.......6",
#  "...7.125.",
#  ".7.61.4.5",
#  ".68.49..2",
#  "..4..58.."]

# no5 = 
#   ['.6......3',
#    '..5.2...4',
#    '9.2.17...',
#    '....5..67',
#    '.1...83..',
#    '..92.1...',
#    '1........',
#    '.......8.',
#    '..83.9...']


no105 =
  ['...2....1',
   '9.7.4....',
   '.4...3...',
   '..3.9.5..',
   '59.......',
   '2...3..8.',
   '..67.4..3',
   '8.......2',
   '....81.4.']

online = 
  ['9...4...1',
   '2...6.59.',
   '.1..5.7..',
   '.....49..',
   '4..9.5..7',
   '..91.....',
   '..5.9..3.',
   '.81.2...9',
   '7...1...8']

initial = no105
puts initial
puts
solution = Grid.new.solve(initial)
puts solution

