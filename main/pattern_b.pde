import java.util.List;
import java.util.LinkedList;
import java.util.Iterator;
import org.hsluv.HUSLColorConverter;
import org.javatuples.Pair;

class PatternB implements Pattern {
  void setup() {
  }
  void draw() {
    if (frameCount % 100 == 0) {
      print("DRAW PATTERN B.");
    }
  }
  void cleanup() {
  }
}

///////////////
/*
 * A bar randomly walks around the screen changing in angle and length.  It emits color that flows
 * away from it.
 *
 */
class ColorEmittingBar implements Pattern {
  LinkedList<PointWithTrail> trails;
  VectorWithColor[] vectorGrid;
  Colormap cm;

  void setup() {
    colorMode(RGB, 255, 255, 255);
    vectorGrid = new VectorWithColor[(height + 2)*(width + 2)];
    trails = new LinkedList<PointWithTrail>();
    trails.add(new PointWithTrail(vectorGrid, width+2, height+2));
  }
  void cleanup() {
  }

  void draw() {
    clear();
    for (PointWithTrail trail : trails) {
      trail.draw();
    }
  }
}

class PointWithTrail {
  boolean DEBUG = false;
  int hue;
  float velocity;
  VectorWithColor[] grid;
  int gridWidth;
  int gridHeight;
  WalkingBar bar;
  LinkedList<VectorInGrid> vs;
  Colormap cm;
  String[] allowedColormaps = {
    "hsi", 
    "prism", 
    "tab10", 
    "tab20", 
    "tab20b", 
    "tab20c", 
    "rainbow", 
    "seismic", 
    "spring", 
    "summer", 
    "terrain", 
    "viridis", 
    "winter"
  };

  PointWithTrail(VectorWithColor[] grid, int gridWidth, int gridHeight) {
    this.hue = int(random(0, 256));
    bar = new WalkingBar(new PVector(width / 2, height / 2), PVector.fromAngle(random(0, 2*PI)), random(20, 150));
    this.velocity = 1;
    this.cm = randomColormap(allowedColormaps);
    this.grid = grid;
    this.gridWidth = gridWidth;
    this.gridHeight = gridHeight;
    this.vs = new LinkedList<VectorInGrid>();
    // Simulate for a while, without drawing, until we have filled the screen
    while (true) {
      populateGrid();
      // Just a heuristic for having filled the grid
      if (grid[0] != null && grid[gridWidth-1] != null && grid[gridWidth*gridHeight-1] != null) {
        break;
      }
    }
  }

  void populateGrid() {
    clearVectorGrid();
    bar.walk();
    hue = incByte(hue);
    addNewVectors();
    updateAndDraw();
  }

  void updateAndDraw() {
    Iterator<VectorInGrid> iter = vs.iterator();
    while (iter.hasNext()) {
      VectorInGrid v = iter.next();
      v.update();
      v.draw();
      if (v.hasLeftGrid()) {
        iter.remove();
      }
    }
  }

  VectorInGrid randomVector(PVector p, float theta) {
    // TODO: create some color maps and use that to get the color instead of "hue"
    VectorWithColor v = new VectorWithColor(p.x, p.y, theta, velocity, cm.getColor(this.hue));
    return new VectorInGrid(v, this.grid);
  }

  /**
   * For pixel at (x,y) this function searches for the closest vector
   * and returns the color of that vector.
   */
  color interpolate(int x, int y) {
    x = x + 1;
    y = y + 1;
    //handle the common case (no interpolation) first
    int idx = y * this.gridWidth + x;
    VectorWithColor v = this.grid[idx];
    if (v != null) {
      return v.c;
    }
    int level = 1;
    while (level <= 1) {
      for (PVector p : getNeighbors(level)) {
        int xx = x + (int)p.x;
        int yy = y + (int)p.y;
        if (xx < 0 || yy < 0 || xx >= this.gridWidth || yy >= this.gridHeight) {
          continue;
        }
        idx = yy * this.gridWidth + xx;
        v = this.grid[idx];
        if (v != null) {
          return v.c;
        }
      }
      level++;
    }
    return color(0);
  }

  /**
   * Create new vectors based on the current position of the bar
   */
  void addNewVectors() {
    for (Pair<PVector, Float> v : bar.vectors()) {
      PVector pt = v.getValue0();
      float theta = v.getValue1();
      vs.add(randomVector(pt, theta));
    }
  }

  void clearVectorGrid() {
    for (int i=0; i<this.gridHeight*this.gridWidth; i++) {
      this.grid[i] = null;
    }
  }

  void draw() {
    populateGrid();
    background(0);
    loadPixels();
    for (int x = 0; x<width; x++) {
      for (int y = 0; y<height; y++) {
        int idx = y*width + x;
        pixels[idx] = interpolate(x, y);
      }
    }
    updatePixels();
    // Draw two dots at the ends of the bar; this can help see how the bar is moving
    // and I've found that to be helpful to better understand what is going on.
    if (this.DEBUG) {
      bar.draw();
    }
  }
}

class WalkingBar {
  float baseXSpeed = 0;
  float baseYSpeed = 0;
  float thetaSpeed = 0;
  float lengthSpeed = 0;
  PVector base;
  PVector slope;
  float len;
  // These are all related to tracking the slope/angle of rotation
  // TODO: abstract this away
  // How far we rotated
  float totalRotation;
  // What direction we are rotating
  // positive = clockwise, negative = counter
  float rotationDirection;
  // how far to rotate
  float targetRotation;
  // null if not in transition, otherwise the frame
  // number that we started transitioning
  Integer startTransition;

  WalkingBar(PVector base, PVector slope, float len) {
    this.base = base;
    this.slope = slope;
    this.len = len;
    this.totalRotation = 0;
    this.rotationDirection = randPosNeg();
    this.targetRotation = 2 * PI;
    this.startTransition = null;
  }

  void draw() {
    PVector start = PVector.add(base, PVector.mult(slope, len / 2));// * slope.dx, base.y + len / 2 * slope.dy);
    PVector end = PVector.add(base, PVector.mult(slope, -len / 2));//new PVector(base.x - len / 2 * slope.dx, base.y - len / 2 * slope.dy);
    fill(color(0, 0, 0));
    ellipse(start.x, start.y, 1, 1);
    fill(color(0, 0, 0));
    ellipse(end.x, end.y, 1, 1);
  }

  void walk() {
    base.x = reflect(base.x + baseXSpeed, 0, width);
    base.y = reflect(base.y + baseYSpeed, 0, height);
    slope.rotate(thetaSpeed);
    totalRotation += abs(thetaSpeed);
    len = reflect(len + lengthSpeed, 20, 150);
    baseXSpeed = reflect(baseXSpeed + random(-.03, .03) + ( width / 2 - base.x) * 0.0001, -.2, .2);
    baseYSpeed = reflect(baseYSpeed + random(-.03, .03) + (height / 2 - base.y) * 0.0001, -.2, .2);

    float maxRotationSpeed = 150.0/len * 0.01;
    float t = frameCount;// / frameRate;
    thetaSpeed = maxRotationSpeed * squareWave();
    lengthSpeed = reflect(lengthSpeed + random(-.01, .01), -1, 1);
    // There is a relationship between length and maximum rotation speed
    // Where speed is radians per frame.
    // Max speed is observational
    // Length : Max Speed : Actual : Period
    //  150   :  0.01     :  0.01  :  200 = 6.6 seconds
    //  100   :  0.02     :  0.015 :  133 = 4.3
    //   50   :  0.04     :  0.03  :   66 = 2.2
    //   25   :  0.1      :  0.06  :   33 = 1.1
    // Though, at really high speeds interesting things can happen
  }

  float squareWave() {
    if (startTransition != null) {
      return transition();
    }
    if (totalRotation > targetRotation) {
      // Need to ease into the transition
      // from 1 -> -1 over N frames
      startTransition = frameCount;
      return transition();
    }
    return rotationDirection;
  }

  float transition() {
    int N = 10; // transition over 1/3 of a second
    assert startTransition != null;
    int n = frameCount - startTransition;
    if (n >= N) {
      startTransition = null;
      rotationDirection *= -1;
      totalRotation = 0;
      targetRotation = 2*PI;
      return squareWave();
    }
    // This gives a smooth value between 0 and 1
    float ss = smoothstep(float(n)/N);
    return rotationDirection * (1 - (2 * ss));
  }

  float smoothstep(float x) {
    return x * x * (3 - 2 * x);
  }

  List<Pair<PVector, Float>> vectors() {
    ArrayList<Pair<PVector, Float>> result = new ArrayList<Pair<PVector, Float>>();
    float startingTheta = slope.heading() + PI/2;
    for (float i=-len / 2; i < len / 2; i+=.5) {
      PVector pt = PVector.add(base, PVector.mult(slope, i));
      result.add(new Pair(pt, startingTheta));
      result.add(new Pair(pt, startingTheta + PI));
    }
    PVector start = PVector.add(base, PVector.mult(slope, len / 2));
    PVector end = PVector.add(base, PVector.mult(slope, - len / 2));
    for (float offset=0; offset<PI; offset+=PI/180) {
      result.add(new Pair(end, startingTheta + offset));
      result.add(new Pair(start, startingTheta + PI + offset));
    }
    return result;
  }
}


// One idea is make Vectors have neighbors and if two neighbors get
// too far apart (like > 1 pixel) then a new vector is created halfway
// between them. Then I wouldn't have to do much interpolation on the
// pixels.  And I could make less vectors at the start.
class VectorInGrid {
  VectorWithColor v;
  VectorWithColor[] grid;
  VectorInGrid(VectorWithColor v, VectorWithColor[] grid) {
    this.v = v;
    // Our grid size is fixed for now.
    // TODO: allow for a more flexible grid size.
    assert grid.length == (width + 2) * (height + 2);
    this.grid = grid;
  }

  void update() {
    this.v.update();
  }

  void draw() {
    if (this.v.isOutOfBounds(1)) {
      return;
    }
    // the vectors array is offset one, so our index needs to change
    // TODO: looking at the profile, the int() calls are the hotspot and taking
    //       up a lot of CPU time.
    this.grid[int(this.v.y + 1)*(width + 2) + int(this.v.x + 1)] = this.v;
  }

  // The vector coordinates are in terms of the screen
  // And we want to keep one extra vector around the edge
  boolean hasLeftGrid() {
    return (v.x < -1 && v.dx < 0) ||
      (v.y < -1 && v.dy < 0) ||
      (v.x >= width + 1 && v.dx > 0) ||
      (v.y >= height + 1 && v.dy > 0);
  }
}


interface Wave {
  float step();
}

class Triangle implements Wave {
  float lastY;
  float dy;
  float minY;
  float maxY;

  Triangle(float dy, float minY, float maxY) {
    this.dy = dy;
    this.minY = minY;
    this.maxY = maxY;
    this.lastY = minY;
  }

  float step() {
    lastY += dy;
    if (lastY > maxY) {
      lastY = maxY - (lastY - maxY);
      dy *= -1;
    } else if (lastY < minY) {
      lastY = minY + (minY - lastY);
      dy *= -1;
    }
    return lastY;
  }
}


private static final int[][] NEIGHBORS = {
  {-1, 0}, { 0, -1}, { 0, 1}, { 1, 0}, 
  { 1, 1}, {-1, 1}, { 1, -1}, {-1, -1}, 
  {-2, 0}, { 2, 0}, { 0, -2}, { 0, 2}, 
  {-2, 1}, {-2, -1}, { 2, -1}, { 2, 1}, 
  { 1, 2}, { 1, 2}
};

IntList getLevelOrder(int level) {
  IntList result = new IntList();
  for (int i=-level; i<=level; i++) {
    result.append(i);
  }
  return result;
}

//TODO: This is also slow
List<PVector> getNeighbors(int level) {
  assert level >= 1;
  List<PVector> result = new ArrayList<PVector>();
  for (int x : getLevelOrder(level)) {
    for (int y : getLevelOrder(level)) {
      if (abs(x) != level && abs(y) != level) {
        continue;
      }
      result.add(new PVector(x, y));
    }
  }
  return result;
}

float reflect(float val, float min, float max) {
  if (val < min) {
    return min + (min - val);
  } else if (val > max) {
    return max - (val - max);
  } else {
    return val;
  }
}
