library bibbler;

import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'dart:convert' show JSON;

part "src/grid.dart";
part "src/tile.dart";
part "src/keyboard_input_manager.dart";
part "src/local_storage_manager.dart";
part "src/html_actuator.dart";
part "src/game_manager.dart";  
part "src/dictionary_manager.dart";

void main() {
  var gameManager = new GameManager(4);
}
