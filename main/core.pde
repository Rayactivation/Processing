import net.markenwerk.utils.lrucache.LruCache;

/**
 * This is the main interface that all of the patterns need to implement
 */
interface Pattern {
  void setup();
  void draw();
  void cleanup();
}

// TODO: rename this!
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


// Other ideas for color maps:
//  - slice (take a slice and then interpolate). This way you can have
//    blues, reds, oranges, etc.
class ArrayColormap implements Colormap {
  color[] arr;
  ArrayColormap (color[] arr) {
    this.arr = arr;
  }
  color getColor(int val) {
    return this.arr[val];
  }
}

Map<String, Colormap> cache = new LruCache<String, Colormap>(10);
Colormap getColormap(String name) {
  if (!cache.containsKey(name)) {
    Colormap cm = readColormap(name);
    cache.put(name, cm);
  }
  return cache.get(name);
}

Colormap readColormap(String name) {
  colorMode(RGB, 255, 255, 255);
  color[] arr = new color[256];
  Table table = loadTable(name + ".csv");
  int rowCount = 0;
  for (TableRow row : table.rows()) {
    color c = color(row.getInt(0), row.getInt(1), row.getInt(2));
    int rr = (c >> 16) & 0xFF;
    int gg = (c >> 8) & 0xFF;
    int bb = c & 0xFF;          
    assert rr == row.getInt(0);
    assert gg == row.getInt(1);
    assert bb == row.getInt(2);
    arr[rowCount] = c;
    rowCount++;
  }
  assert rowCount == 256;
  return new ArrayColormap(arr);
}

int randomByte() {
  return int(random(0, 256));
}

/**
 * Return a random integer between
 * a (inclusive) and b (exclusive)
 */
int randInt(int a, int b) {
  return (int)Math.floor(random(a, b));
}

/**
 * Perception of LED brightness is not linear. This applies a correction
 * so that we get approximately 32 equal steps of brightness
 *
 * Lookup table from:
 * https://ledshield.wordpress.com/2012/11/13/led-brightness-to-your-eye-gamma-correction-no/
 *
 */
int[] BRIGHTNESS = {
  0, 1, 2, 3, 4, 5, 7, 9, 12, 15, 18, 22, 27, 32, 38, 44, 51, 58, 67, 76, 86, 96, 108, 120, 134, 
  148, 163, 180, 197, 216, 235, 255};
int MAX_BRIGHTNESS = BRIGHTNESS.length;


/* Help provide smooth transitions between two values.
 * I generally like the effect of having an animation:
 * - start at one random value
 * - pick a target
 * - smoothly transition to that target
 * - once hitting the target, pick a new target and repeat
 */
class Transition {
  float startTime;
  float startValue;
  float endValue;
  float endTime;
  // This is a linear interpolation. M is our slope, C is the intercept
  float M;
  float C;

  Transition(float startTime, float startValue, float endTime, float endValue) {
    this.startTime = startTime;
    this.startValue = startValue;
    this.endValue = endValue;
    this.endTime = endTime;
    float duration = endTime - startTime;
    float delta = this.endValue - this.startValue;
    this.M = delta / duration;
    this.C = this.startValue - (delta * this.startTime / duration);
  }

  float update(float now) {
    if (now > this.endTime + 100) { 
      println(now + ">" + this.endTime + 100);
    }
    float val = this.M * now + this.C;
    return val;
  }
}

/**
 * Walks around a color wheel.
 * Starts at a given hue and then transitions to
 * a very near complement and so on. Each hue transition
 * happens while the color is dark.
 * The parameters here are tuned so that this looks
 * attractive amongst a group of other pixels that
 * are driven by a `ColorTransition`.
 */
class ColorTransition {
  // At each stage, we transition to a different intensity level
  // One of the four stages will be a transition to a "dark" intensity level
  // When that happens, we also switch out the reference hue.
  final int N_STAGES = 4;
  // Used to pick random bright values with a weighting towards
  // brighter values
  final int[] BRIGHT = {17, 18, 19, 20, 21, 
    22, 23, 24, 25, 26, 22, 23, 24, 25, 26, 
    27, 28, 29, 30, 31, 27, 28, 29, 30, 31, 27, 28, 29, 30, 31};
  final int DARK = 14;

  // Our reference point. ColorTransitions get used as a group
  // and so the hues on each will vary subtly. Need to keep track
  // of this so that we don't drift too far away from the group.
  int referenceHue;
  // Our actual hue. Close to the reference hue (or its complement)
  // but slightly different for aesthetic reasons
  int hue;
  // Which stage we are currently in
  int currentStage;
  // Which of the stages we're going to switch to dark and transition hues
  int switchStage;
  // How long we're going to take to get through the current stage
  // in milliseconds
  Transition transition;
  // How much to update the reference hue by on each step
  // 119 tends to be a good value as its just off of half (128) so we make a slow, pretty walk
  // around the color wheel
  int offset;

  ColorTransition(int referenceHue, int offset) {
    this.referenceHue = referenceHue;
    this.offset = offset;
    setHue();
    this.currentStage = 0;
    setSwitchStage();
    updateTransition();
  }

  void setSwitchStage() {
    switchStage = randInt(0, N_STAGES);
  }

  void updateTransition() {
    int targetIntensity;
    if (currentStage == switchStage) {
      // Go dark
      targetIntensity = BRIGHTNESS[DARK];
    } else {
      // Pick a random bright point
      targetIntensity = BRIGHTNESS[this.BRIGHT[randInt(0, this.BRIGHT.length)]];
    }
    float start = millis();
    float end = start + random(800, 1200);
    float startValue = this.transition == null ? this.BRIGHT[randInt(0, this.BRIGHT.length)] : this.transition.endValue;
    this.transition = new Transition(start, startValue, end, targetIntensity);
  }

  color update() {
    if (millis() >= this.transition.endTime) {
      // We've reached the end of our stage!
      if (currentStage == switchStage) {
        // Since we're at the end of the switchStage, we need
        // to change our reference hue
        updateReferenceHue();
        setHue();
      }
      currentStage = (currentStage + 1) % N_STAGES;
      if (currentStage == 0) {
        // we're back at the start so we need to pick a new stage to switch at
        setSwitchStage();
      }
      updateTransition();
    }
    int intensity = getIntensity();
    // I'm only using (256 hues * 16 intensities) = 4096 colors, so
    // it might be worth precalculating and storing.
    return hsi2rgb(this.hue, 255, intensity);
  }

  int getIntensity() {
    return int(this.transition.update(millis()));
  }

  void setHue() {
    if (this.transition != null) {
      // Ensure we're changing hues only when its dark
      assert this.transition.update(millis()) <= BRIGHTNESS[DARK + 1];
    }
    if (random(1) < 0.00) {
      hue = referenceHue + 128;
    } else {
      hue = referenceHue;
    }
    hue += randInt(-15, 15);
    // Reset hue back inside 0-255
    hue = hue & 0xFF;
  }

  void updateReferenceHue() {
    referenceHue = incByte(referenceHue, this.offset);
  }
}

// http://blog.saikoled.com/post/43693602826/why-every-led-light-should-be-using-hsi
color hsi2rgb(int hue, int sat, int intensity) {
  float r, g, b;
  float H = 2 * PI * hue / float(255); // Convert to radians.
  float S = sat / float(255);          // clamp S and I to interval [0,1]
  float I = intensity / float(255);

  // Math! Thanks in part to Kyle Miller.
  if (H < 2.09439) {
    r = 255*I/3*(1+S*cos(H)/cos(1.047196667-H));
    g = 255*I/3*(1+S*(1-cos(H)/cos(1.047196667-H)));
    b = 255*I/3*(1-S);
  } else if (H < 4.188787) {
    H = H - 2.09439;
    g = 255*I/3*(1+S*cos(H)/cos(1.047196667-H));
    b = 255*I/3*(1+S*(1-cos(H)/cos(1.047196667-H)));
    r = 255*I/3*(1-S);
  } else {
    H = H - 4.188787;
    b = 255*I/3*(1+S*cos(H)/cos(1.047196667-H));
    r = 255*I/3*(1+S*(1-cos(H)/cos(1.047196667-H)));
    g = 255*I/3*(1-S);
  }
  return color(r, g, b);
}
