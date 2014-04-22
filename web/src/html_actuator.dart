part of bibbler;

class HTMLActuator {
  var tileContainer    = querySelector(".tile-container");
  var scoreContainer   = querySelector(".score-container");
  var bestContainer    = querySelector(".best-container");
  var messageContainer = querySelector(".game-message");
  var sharingContainer = querySelector(".score-sharing");
  num score = 0;

  // Continues the game (both restart and keep playing) and clears the message container
  continueGame() { 
    messageContainer.classes..remove("game-won")
                            ..remove("game-over");
  }
  
  actuate(var cells, num score, num bestScore, bool terminated, bool won) {
    
    window.animationFrame.then((_) {
     
      clearContainer(tileContainer);
      for (var row in cells) {
        for (var cell in row) {
          if (cell != null) addTile(cell);
        }
      }   
      
      updateScore(score);
      updateBestScore(bestScore);
  
      if (terminated) message(won);
      
    });
  }
  
  clearContainer(container) {
    while (container.nodes.isNotEmpty) {
      container.nodes.remove(container.nodes.first);
    }
  }
  
  addTile(Tile tile) {
    
    DivElement inner = new DivElement()
        ..classes.add("tile-inner")
        ..text = tile.char
        ..id   = toID(tile.position);
    
    DivElement wrapper = new DivElement() 
        ..nodes.add(inner)
        ..classes.add("tile");
    
    if (tile.previousPosition != null) {
      // Make sure that the tile gets rendered in the previous position first
      var classTag = toClassTag(tile.previousPosition);
      wrapper.classes.add(classTag); 
      
      window.animationFrame.then((_) {
        wrapper.classes
          ..remove(classTag)
          ..add(toClassTag(tile.position));
      });
      
    } else {
      wrapper.classes..add(toClassTag(tile.position))
                     ..add("tile-new");
    }
  
    // Put the tile on the board
    tileContainer.nodes.add(wrapper);
  }
  
  String toClassTag(Cell position) => "position-${position.x + 1}-${position.y + 1}";
  
  String toID(Cell position) => ( pow(2,position.x) * pow(3,position.y) ).toString();
  
  updateScore(num newScore) {
    clearContainer(scoreContainer);
  
    var difference = newScore - score;
    score = newScore;
    scoreContainer.text = score.toString();
  
    if (difference > 0) {
      DivElement addition = new DivElement()
        ..classes.add("score-addition")
        ..text = "+" + difference.toString();
      
      scoreContainer.nodes.add(addition);
    }
  }
  
  updateBestScore(num bestScore) {
    bestContainer.text = bestScore.toString();
  }
  
  toggleSelection(Tile position) {
    querySelector(".position-${position.x + 1}-${position.y + 1}")
        .classes.toggle("tile-selected");
  }
  
  message(bool won) {
    String type    = won ? "game-won" : "game-over";
    String message = won ? "You win!" : "Game over!";
  
    messageContainer..classes.add(type)
                    ..querySelector("p").text = message;
  }
}
