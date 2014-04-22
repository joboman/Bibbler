part of bibbler;

class GameManager {
  num size; //Size of the grid
  num startTiles = 8;
  
  KeyboardInputManager inputManager = new KeyboardInputManager();
  HTMLActuator actuator = new HTMLActuator();
  LocalStorageManager storageManager = new LocalStorageManager();
  DictionaryManager dictionary = new DictionaryManager();
  Grid grid; // Reload grid
  
  num score;
  num bestScore;
  bool over;
  bool won;
  bool continuing;
  // Return true if the game is lost, or has won and the user hasn't kept playing
  bool get terminated => over || (won && !continuing); 
  

  List<Tile> currentTiles  = [];
  
  GameManager(this.size) {
    inputManager.on("submit",      submit);
    inputManager.on("restart",     restart);
    inputManager.on("keepPlaying", keepPlaying);
    inputManager.on("select",      select);
    setup();
  }
  
  void submit() {
    if (dictionary.hasWord(currentTiles)) {
      for (Tile tile in currentTiles) {
        grid.removeTile(tile);
        score += tile.value * currentTiles.length;
      }
    }
    currentTiles = [];
    if (grid.isEmpty) won = true;
    if (!terminated) addRandomTile();
    move(2);
  }
  
  // Restart the game
  void restart() {
    actuator.continueGame(); // Clear the game won/lost message
    setup();
  }
  
  // Keep playing after winning (allows going over 2048)
  void keepPlaying() {
    continuing = true;
    actuator.continueGame(); // Clear the game won/lost message
  }
 
  setup() { // Set up the game
    grid       = new Grid(size);
    score      = 0;
    over       = false;
    won        = false;
    continuing = false;
   
    addStartTiles(); // Add the initial tiles
    move(2);
  }
  
  // Set up the initial tiles to start the game with
  void addStartTiles() {
    for (num x = 0; x < size; x++) {
      for (num y = 2; y <= size; y++) {
        addTile(new Cell(x, size - y ));
      }
    }
  }
  
  void addTile(Cell position) {
    var value = dictionary.randomLetter();
    var tile = new Tile(position, value);
    grid.insertTile(tile);
  }
  
  // Adds a tile in a random position (only in the top row)
  void addRandomTile() {
    var cell = grid.randomAvailableCell();
    if (cell.y == 0) addTile(cell);
    else addRandomTile();
  }
  


  // Sends the updated grid to the actuator
  void actuate() {
    if (storageManager.BestScore < score) storageManager.BestScore = score;
    bestScore  = storageManager.BestScore;
    
    actuator.actuate(grid.cells, score, bestScore, terminated, won);
  }

  // Save all tile positions
  void prepareTiles() {
    for (var row in grid.cells) 
      for (var tile in row) 
        if (tile != null) tile.savePosition();
  }
  // Move a tile and its representation
  void moveTile(Tile tile, Cell cell) {
    grid.cells[tile.x][tile.y] = null;
    grid.cells[cell.x][cell.y] = tile;
    tile.updatePosition(cell);
  }
  
  // Move tiles on the grid in the specified direction
  void move(num direction) {
    // 0: up, 1: right, 2: down, 3: left
    
    var cell, tile;
    var vector     = getVector(direction);
    var traversals = buildTraversals(vector);
    
    // Save the current tile positions
    prepareTiles();
    
    // Traverse the grid in the right direction and move tiles
    for( var x in traversals.x) {
      for (var y in traversals.y) {
        cell = new Cell(x,y);
        tile = grid.cellContent(cell);

        if (tile != null) {
          var farthest = findFarthestPosition(cell, vector); 
          moveTile(tile, farthest);
        }
      }
    }
    if (grid.isFull) over = true;
    actuate();
  }
  
  /* To determine the tile selected from a given number, each square
   * is given a "tag." Each x and y position is labeled with succesive 
   * powers of 2 and 3, respectively. The tile's tag is the product 
   * of its x and y values and thus gives a unique number that
   * represent's the tile's position on the board.
   *
   *        2^0   2^1   2^2   2^3 
   *      =========================
   *  3^0 | 1*1 | 2*1 | 4*1 | 8*1 |
   *      |-----+-----+-----+-----|
   *  3^1 | 1*3 | 2*3 | 4*3 | 8*3 |
   *      |-----+-----+-----+-----|
   *  3^2 | 1*9 | 2*9 | 4*9 | 8*9 |
   *      |-----+-----+-----+-----|
   *  3^3 | 1*27| 2*27| 4*27| 8*27|
   *       ========================
   */
  
  void select(num tag) {
    
    Cell cell = toCell(tag);
    Tile tile = grid.cellContent(cell);
    
    if (terminated) return;
    
    if (currentTiles.length >= 1 && !oneAway(tile, currentTiles.last)) {
      return;
    }   
    
    if (currentTiles.contains(tile)) {
      
      while(currentTiles.contains(tile)) {
        currentTiles.last.selected = false;
        actuator.toggleSelection(currentTiles.last);
        currentTiles.removeLast();
      }
    } 
   
    else {
      currentTiles.add(tile);
      tile.selected = true;
      actuator.toggleSelection(tile);
    }
  }
  
  Cell toCell(num tag){
    num x = 0;
    num y = 0;
    
    while (tag % 2 == 0) {
      x++;
      tag /= 2;
    }
    
    while (tag % 3 == 0) {
      y++;
      tag /= 3;
    }
    
    return new Cell(x,y);
  }
  
  bool oneAway(Tile tile1, Tile tile2) {
    return (tile1.x - tile2.x).abs() <= 1 && 
           (tile1.y - tile2.y).abs() <= 1;
  }
  
  // Get the vector representing the chosen direction
  Cell getVector(num direction) {
    // Vectors representing tile movement
    var map = {
      0: new Cell(0,-1), // Up
      1: new Cell(1, 0), // Right
      2: new Cell(0, 1), // Down
      3: new Cell(-1,0)  // Left
    };
    
    return map[direction];
  }
  
  // Build a list of positions to traverse in the right order
  buildTraversals(Cell vector) {
    var traversals = new Traversal();
  
    for (num pos = 0; pos < size; pos++) {
      traversals..x.add(pos)
                ..y.add(pos);
    }

    // Always traverse from the farthest cell in the chosen direction
    if (vector.x == 1) {
      var listx = [];
      for(num x in traversals.x.reversed) listx.add(x);
      traversals.x = listx;
    }
    if (vector.y == 1) {
      var listy = [];
      for (num y in traversals.y.reversed) listy.add(y);
      traversals.y = listy;
    }
    return traversals;
  }
  
  findFarthestPosition(Cell cell, Cell vector) {
    Cell previous;
  
    // Progress towards the vector direction until an obstacle is found
    do {
      previous = cell;
      cell     = new Cell(previous.x + vector.x, previous.y + vector.y);
    } while (grid.withinBounds(cell) &&
             grid.cellAvailable(cell));
  
    return previous;
  }
}

class Traversal {
  var x = [];
  var y = [];
}