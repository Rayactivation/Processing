class Triangle {
  int wdth, hght;
  float slope;
  PImage clippedImg;

  Triangle() {
    wdth = 100;  // sourcePG must be this size
    hght = 173;  // wdth * sqrt(3)rounded down
    slope = float(wdth)/float(hght);
    clippedImg = createImage(wdth, hght, RGB);
  }


  void clipSourcePG() {
    int x = 0;
    int y = hght-1; // gives bottom left corner of source[] 
    int sourceIndex = x + (y * wdth); // starting position in source image pixels array
    float w = float(wdth); // adjustable wdth to calc diagonal clip
    int cx = 0;
    int cy = hght-1;
    int clippedIndex = cx + (cy * wdth); // starting position in clipped image pixels array

    sourcePG.loadPixels(); 
    clippedImg.loadPixels(); 
    for (int i = 0; i < hght; i++) {
      for (int j = 0; j < wdth; j++) {
        if (j < w) clippedImg.pixels[clippedIndex + j] = sourcePG.pixels[sourceIndex + j];
        else clippedImg.pixels[clippedIndex + j] = color(0, 0);// transparent black
      }
      // calcs for diagonal chop
      w = w - slope;  
      y--; // go up
      sourceIndex = x + (y * wdth);
      cy--;
      clippedIndex = cx + (cy * wdth);
    }
    clippedImg.updatePixels();
    sourcePG.updatePixels();
  }

  void drawImgTri() {
    image(clippedImg, 0, 0);
  }
}


class shapeGen {
  ArrayList<Shape> shapes;
  PVector pos;
  float h;

  shapeGen() {
    pos = new PVector(25, random(80, 160));
    shapes = new ArrayList<Shape>();
    h = 270;
  }

  void run() {
    h = 270 + sin(frameCount * .005) * 90;
    shapes.add(new Shape(pos));
    for (int i = shapes.size ()-1; i >= 0; i--) {
      Shape s = shapes.get(i);
      s.run();
      if (s.isDead()) {
        shapes.remove(i);
      }
    }
  }
}

class Shape {
  PVector pos, vel;
  color c;
  float sze, incr1, incr2, s;

  Shape(PVector p) {
    vel = new PVector(random(-1, 1), random(-1, 1));
    vel.normalize();
    vel.mult(.5);
    pos = p.get();
    c = color(sGen.h, random(10, 100), random(10, 100), random(10, 100));
    sze = random(1, 100);
    incr1 = random(-.02, .02);
    incr2 = random(-.02, .02);
  }

  void run() {
    pos.add(vel);
    next.fill(c);
    if (rtt) s = cos(frameCount * incr2) * sze; // roll
    else s = sze;
    next.pushMatrix();
    next.translate(pos.x, pos.y);
    if (rtt) next.rotate(cos(frameCount * incr1));
    if (isRect) next.rect(0, 0, sze, s);
    else next.ellipse(0, 0, sze, s);
    next.popMatrix();
  }

  boolean isDead() {
    if (pos.y < -50 || pos.y  > 220) return true;
    if (pos.x < -50 || pos.x  > 150) return true;
    else return false;
  }
}
