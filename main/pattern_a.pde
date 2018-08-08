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

  void setup() {
    colorMode(HSB);
    hues = new int[width * height];
    int hue = 0;
    loadPixels();
    for (int i = 0; i < width * height; i++) {
      hue = int(random(0, 360));
      pixels[i] = color(hue, 255, 255);
      hues[i] = hue;
    }
    updatePixels();
  }

  void draw() {
    loadPixels();
    int hue;
    for (int i = 0; i < width * height; i++) {
      int delta;
      if ((frameCount % 60) < 10) {
        // Ocassionaly add in some small bits of randomness
        delta = int(random(1, 3));
      } else {
        delta = 2;
      }
      hue = incByte(hues[i], delta);
      hues[i] = hue;
      pixels[i] = color(hue, 255, 255);
    }
    updatePixels();
  }
}


/*
 * Draws a bunch of balls, each randomly placed, with a random velocity and a random blue-ish color.
 * When the ball goes off the screen a new one is randomly created to take its place.
 */
class RandomLinearBalls implements Pattern {
  LinkedList<Vector> vs;

  void setup() {
    // TODO: switch to HSB, 255, 255, 255
    colorMode(HSB, 360, 100, 100);
    vs = new LinkedList<Vector>();
    for (int i=0; i<300; i++) {
      vs.add(randomVector());
    }
  }

  Vector randomVector() {
    return new Vector(random(0, width), random(0, height), random(0, 2*PI), random(.2, 3), color(random(180, 270), random(70, 100), random(70, 100)));
  }

  void draw() {
    clear();
    Iterator<Vector> iter = vs.iterator();
    int removed = 0;
    while (iter.hasNext()) {
      Vector v = iter.next();
      v.update();
      v.draw();
      if (v.x < 0 || v.y < 0 || v.x > width || v.y > height) {
        iter.remove();
        removed += 1;
      }
    }
    for (int i = 0; i < removed; i++) {
      vs.add(randomVector());
    }
  }
}


class Vector {
  float x;
  float y;
  float dx;
  float dy;
  color c;

  Vector(float x, float y, float theta, float v, color c) {
    this.x = x;
    this.y = y;
    this.dx = v*sin(theta);
    this.dy = v*cos(theta);
    this.c = c;
  }

  void update() {
    this.x += this.dx;
    this.y += this.dy;
  }

  void draw() {
    fill(this.c);
    stroke(this.c);
    ellipse(this.x, this.y, 7, 7);
  }
}
