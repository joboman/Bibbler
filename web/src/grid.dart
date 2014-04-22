part of bibbler;

class Grid{
  num size;
  List cells;

  factory Grid(var param) {
    if(param is num)       return new Grid.empty(param);
    else if(param is List) return new Grid.fromState(param);
    else                   throw  new Error();
  }
  
  Grid.empty(num this.size) { 
    cells = new List(size);
    for (num x = 0; x < size; x++) {
      cells[x] = [];
      for (num y = 0; y < size; y++) {
        cells[x].add(null);
      }
    }
  }
  
  Grid.fromState(List this.cells) {
    this.size = cells.length;
  }
  
  // Find the first available random position
  Cell randomAvailableCell() {
    Random rand = new Random();
    var cells = availableCells();
    if (cells.length != 0) {
      return cells[rand.nextInt(cells.length)];
    }
    throw new Error();
  }
  
  
  List<Cell> availableCells() {
    var availableCells = [];
    for (var x = 0; x < cells.length; x++) {
      for (var y = 0; y < cells[0].length; y++) {
        if (cells[x][y] == null) availableCells.add(new Cell(x,y));
      }
    }
    return availableCells;
  }
  
  
  bool get isFull          => availableCells().length == 0;
  bool get isEmpty         => availableCells().length == size * size;
  bool cellAvailable(cell) => !cellOccupied(cell);
  bool cellOccupied(cell)  => cellContent(cell) != null;
  Tile cellContent(cell)   => withinBounds(cell) ? cells[cell.x][cell.y] : null;
  
  bool withinBounds(position) {
    return position.x >= 0 && position.x < size &&
           position.y >= 0 && position.y < size;
  }
  
  // Inserts a tile at its position
  void insertTile(tile) {
    cells[tile.x][tile.y] = tile;
  }
  void removeTile(tile) {
    cells[tile.x][tile.y] = null;
  }
}

class Cell {
  int x;
  int y;
  Cell(this.x, this.y);
}


