part of bibbler;

class DictionaryManager {
  
  String scrabbleLetters = 'AAAAAAAAABBCCDDDDEEEEEEEEEEEEFFGGGHHIIIIIIIIIJKLLLLMMNNNNNNOOOOOOOOPPQRRRRRRSSSSTTTTTTUUUUVVWWXYYZ';
  List<String> words = [];
  
  handleError(error) => window.alert("Error initializing words: $error");

  DictionaryManager() {
    var path = 'src/words.json';
    HttpRequest.getString(path)
        .then((jsonString) => words = JSON.decode(jsonString))
        .catchError(handleError);
  }
  
  bool hasWord(List<Tile> tiles) {
    String letterList = "";
    for (Tile tile in tiles) letterList += tile.char.toLowerCase();
    
    return words.contains(letterList);
  }
  
  String randomLetter() {
    Random indexGenerator = new Random();
    int letterIndex = indexGenerator.nextInt(scrabbleLetters.length);
    String letter = scrabbleLetters[letterIndex];
    scrabbleLetters = scrabbleLetters.replaceFirst(letter, '');
    return letter;
  }
}

