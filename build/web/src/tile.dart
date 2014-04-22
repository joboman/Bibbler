part of bibbler;

class Tile {
  num x;
  num y;
  num value;
  String char;
  Cell previousPosition;
  bool selected = false;
  
  Cell get position => new Cell(x,y);
  
  Tile(Cell position, String this.char) {
    if (char.length != 1) throw new Error();
    this.x                = position.x;
    this.y                = position.y;
    this.value = scrabbleValues[char];
 
    this.previousPosition = null;
  }
  
  savePosition() => previousPosition = new Cell(x,y);
  
  updatePosition(Cell position) {
    this.x = position.x;
    this.y = position.y;
  }
  
  serialize() => this; 
  
  Map scrabbleValues = { 'A':1, 'E':1, 'I':1, 'L':1, 'N':1,
                         'O':1, 'R':1, 'S':1, 'T':1, 'U':1,
                         'D':2, 'G':2, 'B':3, 'C':3, 'M':3,
                         'P':3, 'F':4, 'H':4, 'V':4, 'W':4,
                         'Y':4, 'K':5, 'J':8, 'X':8, 'Q':10,
                         'Z':10, ' ':0 };
}


