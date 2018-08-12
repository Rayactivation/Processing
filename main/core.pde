import net.markenwerk.utils.LruCache;

/**
 * This is the main interface that all of the patterns need to implement
 */
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

class Vector {
  float x;
  float y;
  float dx;
  float dy;

  /**
   * Construct a new vector
   * x: current x position
   * y: current y position
   * theta: angle of movement
   * v: velocity of movement
   */
  Vector(float x, float y, float theta, float v) {
    this.x = x;
    this.y = y;
    this.dx = v*cos(theta);
    this.dy = v*sin(theta);
  }

  /**
   * Update the vector's location
   */
  void update() {
    this.x += this.dx;
    this.y += this.dy;
  }

  /**
   * Checks if the vector is still on the screen.
   */
  boolean isOutOfBounds(int margin) {
    return (this.x < -margin || this.y < -margin ||
      this.x >= width + margin || this.y >= height + margin);
  }
  boolean isOutOfBounds() {
    return isOutOfBounds(0);
  }
}

class VectorWithColor extends Vector {
  color c;

  VectorWithColor(float x, float y, float theta, float v, color c) {
    super(x, y, theta, v);
    this.c = c;
  }
}

// increment a byte value
// Wraps from 255 -> 0
// This is 4x faster than using mod.
int incByte(int hue) {
  return incByte(hue, 1);
}

int incByte(int hue, int delta) {
  return (hue + delta) & 0xFF;
}


class Timer {
  int startTime;
  int elapsedTime;
  int timeBase;

  Timer(int timeBase) {
    this.timeBase = timeBase;
    startTime = millis();
  }

  boolean check() {
    if (millis() - startTime >= timeBase) {
      startTime = millis();
      return true;
    } 
    return false;
  }
  void timeUp() {
    timeBase+=2;
  }
  void timeDown() {
    timeBase-=2;
  }
}

interface Colormap {
  /**
   * Return a color.  The input needs to be between 0 <= val <= 255.
   */
  color getColor(int val);
}

Map<String, Colormap> cache = new LruCache<String, Colormap>(cacheSize);
Colormap getColormap(String name) {
  return cache.get(name);
}
