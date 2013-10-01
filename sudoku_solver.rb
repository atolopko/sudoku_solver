require 'Set'

class Cell
  include Comparable

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
      (1..9).to_set.delete(value).each { |candidate| eliminate(candidate) }
      self
    end
  end

  def eliminate(candidate)
    unless solved?
      if candidates.delete(candidate)
        # puts "eliminated #{candidate} from #{[@row,@col]}"
        if solved?
          puts "solved #{self} via elimination"
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

  def <=>(other)
    row * 9 + col <=> other.row * 9 + other.col
  end
end

class Grid
  attr_reader :g

  def initialize(initial)
    @g = (0..8).map { |row| (0..8).map { |col| Cell.new(row, col, self) } }
    (0..8).each do |row| 
      (0..8).each do |col|
        value = initial[row][col].to_i
        if (1..9).include?(value)
          g[row][col].solve(value) 
        end
      end
    end
  end

  def solve
    # puts "setting #{row},#{col} with #{value}"
    progress = true
    n = 0
    while !solved? && progress
      progress = false
      n += 1
      puts "loop #{n}"
      (1..9).each do |candidate|
        (0..8).each do |i|
          progress ||= 
            test_row_solved_for(i, candidate) ||
            test_col_solved_for(i, candidate) ||
            test_box_solved_for(3 * (i / 3), 3 * (i % 3), candidate)
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
    test_element_solved_for(g[row], value, 'row')
  end

  # if a cell in the col is the only one with the candidate value, it
  # must be that value
  def test_col_solved_for(col, value)
    # puts "test_col_solved_for(#{col}, #{value})"
    test_element_solved_for(column(col), value, 'col')
  end

  # if a cell in the box is the only one with the candidate value, it
  # must be that value
  def test_box_solved_for(row, col, value)
    # puts "test_box_solved_for(#{row}, #{col}, #{value})"
    test_element_solved_for(box(row, col), value, 'box')
  end

  def test_element_solved_for(cells, value, element)
    cells_with_value =
      cells.select { |cell| cell.candidates.include?(value) }
    if cells_with_value.size == 1
      cell = cells_with_value.first.solve(value)
      puts "solved #{cells_with_value.first} in #{element}"
    end
  end
     
  def eliminate_from_related_cells(solved_cell)
    if solved_cell.solved?
      (row(solved_cell.row) + 
       col(solved_cell.col) + 
       box(solved_cell.row, solved_cell.col)).
        to_set.
        delete(solved_cell).
        each { |cell| cell.eliminate(solved_cell.value) }
    end
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
