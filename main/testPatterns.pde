// Contains patterns that are useful for testing layouts, osc, etc

class LeftRight implements Pattern {
  Triangle x;
  void setup() {
    x = new Triangle(1, 0, width);
  }
  void cleanup() {}
  void draw() {
    background(0);
    float val = x.step();
    stroke(#FFFFFF);
    line(val, 0, val, height);
  }
}

class UpDown implements Pattern {
  Triangle y;
  void setup() {
    y = new Triangle(1, 0, height);
  }
  void cleanup() {}
  void draw() {
    background(0);
    float val = y.step();
    stroke(#FFFFFF);
    line(0, val, width, val);
  }
}
