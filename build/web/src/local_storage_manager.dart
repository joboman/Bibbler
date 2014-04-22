part of bibbler;

class LocalStorageManager {
  final String BEST_SCORE_KEY = "bestScore";
  Storage storage = window.localStorage;
  
  get BestScore =>
    storage.containsKey(BEST_SCORE_KEY) ? 
      int.parse(storage[BEST_SCORE_KEY]) : 0;
  
  set BestScore(num score) => storage[BEST_SCORE_KEY] = score.toString();
  
}