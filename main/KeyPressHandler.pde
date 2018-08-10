//TODO - setup an animation cycler

void keyPressed() {
  //place holder key press handler
  if (key == 'a' || key == 'A') {
    println("a pressed");
    nextPattern();
  }
}

void mouseClicked(){
  nextPattern();
}
