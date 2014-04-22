part of bibbler;

class KeyboardInputManager {
  var events = {};

  on(String eventTag, callback) {
    if (!events.containsKey(eventTag)) events[eventTag] = [];
    events[eventTag].add(callback);
  }
  
  KeyboardInputManager() {
    // Respond to key presses
    document.onKeyDown.listen((KeyboardEvent event) {
      bool modifiers = event.altKey || event.ctrlKey || 
                       event.metaKey|| event.shiftKey;

      // Ignore the event if it's happening in a text field
      if (!targetIsInput(event) && !modifiers) {
        switch (event.which) {
          
          //Enter key cues a submission
          case 13:
            submit(event);
            break;
  
          //R key restarts the game
          case 82:
            restart(event);
            break;
        }
      }
    });
    
    document.onClick.listen((MouseEvent event) {
      Element target = event.target;
      if (target.className == "tile-inner") select(event);
    }); 
  
    // Respond to button presses
    bindButtonPress(".retry-button", restart);
    bindButtonPress(".restart-button", restart);
    bindButtonPress(".keep-playing-button", keepPlaying);
  }
  
  targetIsInput(event) => 
      event.target.tagName.toLowerCase() == "input";
  
  bindButtonPress(selector, function) => 
      querySelectorAll(selector).onClick.listen(function);
  
  select(event) {
    var tag = event.target.id;
    event.preventDefault();
    emit("select", int.parse(tag));
  }
  
  restart(event) {
    event.preventDefault();
    emit("restart");
  }
  
  keepPlaying(event) {
    event.preventDefault();
    emit("keepPlaying");
  }
  
  submit(event) {
    event.preventDefault();
    emit("submit");
  }
  
  emit(String eventTag, [data]) {
    if (events.containsKey(eventTag)) {
      var callbacks = events[eventTag];
      for (var callback in callbacks) {
        if (data != null) callback(data);
        else callback();
      }
    }
  }
}



