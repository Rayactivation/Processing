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
    cm = getColormap("hsi");
    vs = new LinkedList<EllipseAtVector>();
    for (int i=0; i<300; i++) {
      vs.add(randomVector());
    }
  }
  void cleanup() {
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
    t = new ColorTransition(0);
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
