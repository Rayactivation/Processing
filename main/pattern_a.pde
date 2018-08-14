import java.util.LinkedList;
import java.util.Iterator;


class PatternA implements Pattern {
  void setup() {
  }

  void draw() {
    if (frameCount % 100 == 0) {
      print("DRAW PATTERN A.");
    }
  }

  void cleanup() {
  }
}

/* Populates the screen with random colors
 * and then slowly the patterns evolve
 */
// The results seem to a lot of yellow.
// I'd be curious what would happen if
// it was restricted to just a slice of the color
// wheel, like, what if it was just shades of blue?
class RandomEbb implements Pattern {
  int[] hues;
  Colormap cm;

  void setup() {
    hues = new int[width * height];
    int hue = 0;
    cm = getColormap("hsi");
    loadPixels();
    for (int i = 0; i < width * height; i++) {
      hue = randomByte();
      pixels[i] = cm.getColor(hue);
      hues[i] = hue;
    }
    updatePixels();
  }
  void cleanup() {
  }

  void draw() {
    loadPixels();
    int hue;
    for (int i = 0; i < width * height; i++) {
      int delta;
      if ((frameCount % 60) < 10) {
        // Ocassionaly add in some small bits of randomness
        delta = int(random(1, 4));
      } else {
        delta = 2;
      }
      hue = incByte(hues[i], delta);
      hues[i] = hue;
      pixels[i] = cm.getColor(hue);
    }
    updatePixels();
  }
}


/*
 * Draws a bunch of balls, each randomly placed, with a random velocity and a random blue-ish color.
 * When the ball goes off the screen a new one is randomly created to take its place.
 */
class RandomLinearBalls implements Pattern {
  LinkedList<EllipseAtVector> vs;
  Colormap cm;

  void setup() {
    cm = randomColormap();
    vs = new LinkedList<EllipseAtVector>();
    for (int i=0; i<300; i++) {
      vs.add(randomVector());
    }
  }
  void cleanup() {
  }

  Colormap randomColormap() {
    String[] colormaps = {"prism", 
      "rainbow", 
      "seismic", 
      "spring", 
      "summer", 
      "tab10", 
      "tab20", 
      "tab20b", 
      "tab20c", 
      "terrain", 
      "viridis", 
      "winter"
    };
    String name = colormaps[randInt(0, colormaps.length)];
    println("Using colormap " + name);
    return getColormap(name);
  }

  EllipseAtVector randomVector() {
    color c = cm.getColor(randomByte());
    VectorWithColor v = new VectorWithColor(random(0, width), random(0, height), random(0, 2*PI), random(.2, 3), c);
    return new EllipseAtVector(v);
  }

  void draw() {
    clear();
    Iterator<EllipseAtVector> iter = vs.iterator();
    int removed = 0;
    while (iter.hasNext()) {
      EllipseAtVector v = iter.next();
      v.update();
      v.draw();
      if (v.isOutOfBounds()) {
        iter.remove();
        removed += 1;
      }
    }
    for (int i = 0; i < removed; i++) {
      vs.add(randomVector());
    }
  }
}


class EllipseAtVector {
  VectorWithColor v;
  int diameter = 7;
  EllipseAtVector(VectorWithColor v) {
    this.v = v;
  }

  void update() {
    this.v.update();
  }

  void draw() {
    fill(this.v.c);
    stroke(this.v.c);
    ellipse(this.v.x, this.v.y, this.diameter, this.diameter);
  }

  boolean isOutOfBounds() {
    return this.v.isOutOfBounds();
  }
}

class TestColorTransition implements Pattern {
  ColorTransition t;
  void setup() {
    colorMode(RGB, 255, 255, 255);
    t = new ColorTransition(0, 119);
  }
  void cleanup() {
  }
  void draw() {
    colorMode(RGB, 255, 255, 255);
    background(t.update());
    drawGrid();
  }

  void drawGrid() {
    // Draw a grid of all 32 brightness levels
    int brightness = 0;
    for (int x=width/8; x<width; x+=width/9) {
      for (int y=height/4; y<height; y+=height/5) {
        if (brightness >= MAX_BRIGHTNESS) {
          break;
        }
        int intensity = BRIGHTNESS[brightness];
        color c = hsi2rgb(t.hue, 255, intensity);
        fill(c);
        noStroke();
        ellipse(x, y, 10, 10);
        brightness++;
      }
    }
  }
}

class ColorTransitions implements Pattern {
  List<Pair<ColorTransition, Quartet<Integer, Integer, Integer, Integer>>> ct;
  void setup() {
    int hue = randomByte();
    ct = new ArrayList<Pair<ColorTransition, Quartet<Integer, Integer, Integer, Integer>>>();
    int dx = width / 20;
    int dy = height / 20;
    for (int x=0; x<width; x+=dx) {
      for (int y=0; y<width; y+=dy) {
        ct.add(new Pair<ColorTransition, Quartet<Integer, Integer, Integer, Integer>>(new ColorTransition(hue, 119), new Quartet(x, y, dx, dy)));
      }
    }
  }
  void cleanup() {
  }
  void draw() {
    noStroke();
    for (Pair<ColorTransition, Quartet<Integer, Integer, Integer, Integer>> c : ct) {
      fill(c.getValue0().update());
      Quartet<Integer, Integer, Integer, Integer> p = c.getValue1();
      rect(p.getValue0(), p.getValue1(), p.getValue2(), p.getValue3());
    }
  }
}

class ColorTransitionsDown implements Pattern {
  List<Pair<ColorTransition, Quartet<Integer, Integer, Integer, Integer>>> ct;
  int yOffset;
  int dy;
  void setup() {
    yOffset = 0;
    int hue = randomByte();
    ct = new ArrayList<Pair<ColorTransition, Quartet<Integer, Integer, Integer, Integer>>>();
    int dx = width / 20;
    dy = height / 20;
    for (int x=0; x<width; x+=dx) {
      for (int y=-dy; y<width; y+=dy) {
        ct.add(new Pair<ColorTransition, Quartet<Integer, Integer, Integer, Integer>>(new ColorTransition(hue, 119), new Quartet(x, y, dx, dy)));
      }
    }
  }
  void cleanup() {
  }
  void draw() {
    if (frameCount % 5 == 0) {
      yOffset = (yOffset + 1) % (height + dy);
    }
    background(0);
    noStroke();
    for (Pair<ColorTransition, Quartet<Integer, Integer, Integer, Integer>> c : ct) {
      fill(c.getValue0().update());
      Quartet<Integer, Integer, Integer, Integer> p = c.getValue1();
      rect(p.getValue0(), (p.getValue1() + yOffset) % (height + dy) - dy, p.getValue2(), p.getValue3());
    }
  }
}

class ColorTransitionsMove implements Pattern {
  ColorTransition[][] ct;
  float yOffset;
  float xOffset;
  float dy;
  float dx;
  boolean moveRows;
  // -1 to move the row left, 1 to move the row right, 0 to stay
  Integer[] rows;
  // -1 to move the column up, 1 to move the column down, 0 to stay
  Integer[] columns;
  int nRows;
  int nCols;
  void setup() {
    // This is a very different pattern with a small number of rows
    // and a large number of rows.  Both are interesting
    // TODO: have more control over this.  This is unlikely to have 
    //       both dx, and dy small.  Squares are unlikely, etc.
    dx = random(2, width/2);
    dy = random(2, height/2);  
    nRows = int(height / dy + 2); // y
    nCols = int(width / dx + 2); // x
    rows = new Integer[nRows];
    columns = new Integer[nCols];
    int hue = randomByte();
    ct = new ColorTransition[nCols + 1][nRows + 1];
    // Subtract two because we need one extra rectangle to the left
    // and one to the right.
    dx = float(width) / (nCols - 2); // dx*(ncols - 2) = w; ncols = w / dx - 2 
    // Same here, we need one above and one below.
    dy = float(height) / (nRows - 2);
    println(dx, dy);
    for (int x=0; x<nCols; x++) {
      for (int y=0; y<nRows; y++) {
        ct[x][y] = new ColorTransition(hue, 78);
      }
    }
    reset();
  }
  void cleanup() {
  }
  void draw() {
    background(0);
    noStroke();
    xOffset += dx / (1*frameRate);
    yOffset += dy / (1*frameRate);
    float myYOffset = 0;
    float myXOffset = 0;
    for (int x=0; x<nCols; x++) {
      for (int y=0; y<nRows; y++) {
        myYOffset = yOffset * columns[x];
        myXOffset = xOffset * rows[y];
        fill(ct[x][y].update());
        rect((x-1)*dx + myXOffset, (y-1)*dy + myYOffset, dx, dy);
      }
    }
    // Could also check that a full period (1 second) has passed
    if (moveCols() && yOffset >= dy) {
      for (int i=0; i<nCols; i++) {
        int dir = columns[i];
        if (dir == -1) {
          cycleUp(i);
        } else if (dir == 1) {
          cycleDown(i);
        }
      }
      reset();
    } else if (moveRows && xOffset >= dx) {
      for (int i=0; i<nRows; i++) {
        int dir = rows[i];
        if (dir == -1) {
          cycleLeft(i);
        } else if (dir == 1) {
          cycleRight(i);
        }
      }
      reset();
    }
  }
  void reset() {
    yOffset = 0;
    xOffset = 0;
    if (random(1) < 0.5) {
      moveRows = true;
      for (int i=0; i<nRows; i++) {
        rows[i] = randInt(-1, 2);
      }
      for (int i=0; i<nCols; i++) {
        columns[i] = 0;
      }
    } else {
      moveRows = false;
      for (int i=0; i<nRows; i++) {
        rows[i] = 0;
      }
      for (int i=0; i<nCols; i++) {
        columns[i] = randInt(-1, 2);
      }
    }
  }
  boolean moveCols() { 
    return !moveRows;
  }
  void cycleDown(int column) {
    ColorTransition tmp = ct[column][nRows-1];
    for (int y=nRows-1; y>0; y--) {
      ct[column][y] = ct[column][y-1];
    }
    ct[column][0] = tmp;
  }
  void cycleUp(int column) {
    ColorTransition tmp = ct[column][0];
    for (int y=0; y<nRows-1; y++) {
      ct[column][y] = ct[column][y+1];
    }
    ct[column][nRows-1] = tmp;
  }
  void cycleRight(int row) {
    ColorTransition tmp = ct[nCols-1][row];
    for (int x=nCols-1; x>0; x--) {
      ct[x][row] = ct[x-1][row];
    }
    ct[0][row] = tmp;
  }
  void cycleLeft(int row) {
    ColorTransition tmp = ct[0][row];
    for (int x=0; x<nCols-1; x++) {
      ct[x][row] = ct[x+1][row];
    }
    ct[nCols-1][row] = tmp;
  }
}

class DLA {
  List<PVector> coalition;
  PVector candidate;
  PVector target;
  int direction;

  DLA(PVector target, int direction) {
    this.target = target;
    this.direction = direction;
    setup();
  }
  void setup() {
    coalition = new ArrayList<PVector>();
    // TODO: actually find the wingtips
    coalition.add(target);
    candidate = new PVector(width/2, height/2);
  }
  void cleanup() {
  }
  void draw() {
    boolean reset = false;
    float start = millis();
    // Use up half of our allotted time to simulate;
    float end = start + (.5 / frameRate);
    while (millis() < end) {
      boolean found = false;
      for (PVector pv : coalition) {
        if (pv.dist(candidate) < 3) {
          coalition.add(candidate);
          found = true;
          if (candidate.x <= width/2 + 1) {
            reset = true;
          }
          candidate = new PVector(width/2, height/2 + randInt(-2, 3));
          break;
        }
      }
      candidate = candidate.add(direction, randInt(-2, 3));
      if (candidate.x > width) {
        candidate = new PVector(width/2, height/2);
      }
      if (found) {
        break;
      }
    }
    for (PVector pv : coalition) {
      fill(0);
      ellipse(pv.x, pv.y, 3, 3);
    }
    if (reset) { 
      setup();
    }
  }
}
