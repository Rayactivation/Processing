interface Pattern {
  void setup();
  void draw();
}

class Point {
  float x;
  float y;

  Point(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

// increment a byte value
// Wraps from 255 -> 0
// This is 4x as fast as using mod.
int incByte(int hue) {
  return incByte(hue, 1);
}

int incByte(int hue, int delta) {
  return (hue + delta) & 0xFF;
}
