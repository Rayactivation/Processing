import java.util.List;
import java.util.LinkedList;
import java.util.Iterator;
import org.hsluv.HUSLColorConverter;

class PatternB implements Pattern {
  void setup() {
  }
  void draw() {
    if (frameCount % 100 == 0) {
      print("DRAW PATTERN B.");
    }
  }
}

///////////////
/*
 * A bar randomly walks around the screen changing in angle and length.  It emits color that flows
 * away from it.
 *
 */
// This is in massive need of refactoring!
class ColorEmittingBar implements Pattern {
  LinkedList<PointWithTrail> trails;
  Vector[] vectorGrid;

  void setup() {
    //colorMode(RGB, 255, 255, 255);
    colorMode(HSB, 360, 100, 100);
    vectorGrid = new Vector[(height + 2)*(width + 2)];
    trails = new LinkedList<PointWithTrail>();
    trails.add(new PointWithTrail(vectorGrid));
  }

  void draw() {
    int start = millis();
    clear();
    for (PointWithTrail trail : trails) {
      trail.draw();
    }
    int end = millis();
    if (end - start > 1000 / frameRate) {
      print("Frame took too long");
    }
  }
}

class PointWithTrail {
  float hue;
  Point base;
  Slope slope;
  float length;
  float velocity;
  Vector[] grid;
  LinkedList<VectorInGrid> vs;
  // TODO: are these used?
  int nBalls;
  int nBallsPerStep;
  Triangle wave;

  PointWithTrail(Vector[] grid) {
    this.hue = 0; //random(0, 360);
    this.base = new Point(width / 2, height / 2);
    this.slope = new Slope(0);
    this.length = 75;
    this.velocity = 1;
    this.grid = grid;
    this.vs = new LinkedList<VectorInGrid>();
    addNewVectors();
  }

  VectorInGrid randomVector(Point p, float hue, float theta) {
    // TODO: create some color maps and use that to get the color instead of "hue"
    //
    // Dammit, the HSLUV looks terrible :/
    //double[] rgb = HUSLColorConverter.hsluvToRgb(new double[]{hue, 100, 50});
    //print(rgb[0], rgb[1], rgb[2]);
    //int x = 1/0;
    //return new Vector(p.x, p.y, theta, velocity, color((int)(rgb[0] * 255), (int)(rgb[1]*255), (int)(rgb[2]*255)));

    //float startHue = 160;
    //float endHue = 260;
    //float rate = ((endHue - startHue) / 180);
    //if (hue < 180) {
    //  hue = rate*hue + startHue;
    //} else {
    //  hue = -rate*hue + (endHue - startHue) + endHue;
    //}
    Vector v = new Vector(p.x, p.y, theta, velocity, color(hue, 100, 100));
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
    int idx = y*(width+2) + x;
    Vector v = this.grid[idx];
    if (v != null) {
      return v.c;
    }
    int level = 1;
    while (level <= 1) {
      for (Point p : getNeighbors(level)) {
        int xx = x + (int)p.x;
        int yy = y + (int)p.y;
        if (xx < 0 || yy < 0 || xx >= width + 2 || yy >= height + 2) {
          continue;
        }
        idx = yy*(width+2) + xx;
        v = this.grid[idx];
        if (v != null) {
          return v.c;
        }
      }
      level++;
    }
    return color(0);
  }

  void addNewVectors() {
    float startingTheta = slope.theta + PI/2;
    Point start = new Point(base.x + length / 2 * slope.dx, base.y + length / 2 * slope.dy);
    Point end = new Point(base.x - length / 2 * slope.dx, base.y - length / 2 * slope.dy);
    for (float i=-length / 2; i < length / 2; i+=.5) {
      Point pt = new Point(base.x + i * slope.dx, base.y + i * slope.dy);
      vs.add(randomVector(pt, hue, startingTheta));
      vs.add(randomVector(pt, hue, startingTheta + PI));
    }
    for (float offset=0; offset<PI; offset+=PI/180) {
      vs.add(randomVector(end, hue, startingTheta + offset));
      vs.add(randomVector(start, hue, startingTheta + PI + offset));
      //break;
    }
  }

  // Be slightly bigger than the actual screen so that
  // interpolation of missing pixels at the edge is easier
  //
  // TODO: make a "VectorGrid" so that converting from "pixel space"
  //       to "vector space" is easier
  void clearVectorGrid() {
    for (int i=0; i<(height+2)*(width+2); i++) {
      this.grid[i] = null;
    }
  }

  void draw() {
    background(0);
    clearVectorGrid();
    Iterator<VectorInGrid> iter = vs.iterator();
    while (iter.hasNext()) {
      VectorInGrid v = iter.next();
      v.update();
      v.draw();
      if (v.hasLeftGrid()) {
        iter.remove();
      }
    }
    loadPixels();
    for (int x = 0; x<width; x++) {
      for (int y = 0; y<height; y++) {
        int idx = y*width + x;
        pixels[idx] = interpolate(x, y);
      }
    }
    updatePixels();

    //Point start = new Point(base.x + length / 2 * slope.dx, base.y + length / 2 * slope.dy);
    //Point end = new Point(base.x - length / 2 * slope.dx, base.y - length / 2 * slope.dy);
    //fill(color(0, 0, 0));
    //ellipse(start.x, start.y, 1, 1);
    //fill(color(0, 0, 0));
    //ellipse(end.x, end.y, 1, 1);

    walk();
    hue = (hue + 1) % 360;
    addNewVectors();
  }

  float baseXSpeed = 0;
  float baseYSpeed = 0;
  float thetaSpeed = 0;
  float lengthSpeed = 0;

  void walk() {
    base.x = reflect(base.x + baseXSpeed, 0, width);
    base.y = reflect(base.y + baseYSpeed, 0, height);
    slope.setTheta(slope.theta + thetaSpeed);
    length = reflect(length + lengthSpeed, 20, 150);
    baseXSpeed = reflect(baseXSpeed + random(-.03, .03) + ( width / 2 - base.x) * 0.0001, -.2, .2);
    baseYSpeed = reflect(baseYSpeed + random(-.03, .03) + (height / 2 - base.y) * 0.0001, -.2, .2);
    // This is not enough rotation change. I'd like to have something that changes direction
    // fairly often, but doesn't spend much time around zero
    //thetaSpeed = reflect(thetaSpeed + random(-.0005, .0005), -.02, .02);
    float maxRotationSpeed = 150.0/length * 0.01;
    float t = frameCount;// / frameRate;
    thetaSpeed = maxRotationSpeed * sin(t * maxRotationSpeed / PI);
    lengthSpeed = reflect(lengthSpeed + random(-.01, .01), -1, 1);
    // There is a relationship between length and maximum rotation speed
    // Lenght : Max Speed
    // 150 : 0.01
    // 100 : 0.02
    //  50 : 0.04
    //  25 : 0.1
    // Though, at really high speeds interesting things can happen
  }
}

// One idea is make Vectors have neighbors and if two neighbors get
// too far apart (like > 1 pixel) then a new vector is created halfway
// between them. Then I wouldn't have to do much interpolation on the
// pixels.  And I could make less vectors at the start.
class VectorInGrid {
  Vector v;
  Vector[] grid;
  VectorInGrid(Vector v, Vector[] grid) {
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
    assert this.v.y + 1 >= 0: "y is too small";
    assert this.v.y + 1 < height + 2: "y is too big"; 
    assert this.v.x + 1 >= 0: "x is too small";
    assert this.v.x + 1 < width + 2: "x is too big";    
    // the vectors array is offset one, so our index needs to change
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


class Slope {
  private float theta;
  float dx;
  float dy;

  Slope(float theta) {
    setTheta(theta);
  }

  void setTheta(float theta) {
    this.theta = theta;
    this.dx = cos(theta);
    this.dy = sin(theta);
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

//Point center;

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

List<Point> getNeighbors(int level) {
  assert level >= 1;
  List<Point> result = new ArrayList<Point>();
  for (int x : getLevelOrder(level)) {
    for (int y : getLevelOrder(level)) {
      if (abs(x) != level && abs(y) != level) {
        continue;
      }
      result.add(new Point(x, y));
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
