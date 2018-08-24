/*

 Pattern Ideas
 Noinput
 - dimonds that progress outward from the center
 -lepord spots
 
 Input
 -Two controlled ball that explode when they hit
 
 */
class ColorMapFadder implements Pattern {

  Colormap cm;
  int i;
  void setup() {
    //    colormapProps.put("hsi", true);
    //colormapProps.put("prism", true);
    //colormapProps.put("tab10", true);
    //colormapProps.put("tab20", true);
    //colormapProps.put("tab20b", true);
    //colormapProps.put("tab20c", true);
    //// These need to be reflected
    //colormapProps.put("rainbow", false);
    //colormapProps.put("seismic", false);
    //colormapProps.put("spring", false);
    //colormapProps.put("summer", false);
    //colormapProps.put("terrain", false);
    //colormapProps.put("viridis", false);
    //colormapProps.put("winter", false);

    cm = getColormap("hsi");
    i = 0;
    println("In colorMapFader");
  }

  void cleanup() {
  }

  void draw() {
    i++;
    background(cm.getColor(i));
  }
}

class primeFade implements Pattern {

  int i, incVal;

  void setup() {
    colorMode(RGB);
    println("In primeFade");
    i = 0;
    incVal = 3;
  }

  void cleanup() {
  }

  void draw() {
    background(0);
    i+= incVal;
    println("i value is " + i);
    if ( i > ((255 * 6) -1)) {
      i = 0;
    }
    if ( i < 255) {
      background(i, 0, 0);
    } else if (i < 255 * 2) {
      background( 255 - (i % 255), 0, 0);
    } else if ( i < 255 * 3) {
      background(0, i % 255, 0);
    } else if ( i < 255 * 4) {
      background(0, 255 - (i % 255), 0);
    } else if ( i < 255 * 5) {
      background(0, 0, i % 255);
    } else {
      background(0, 0, 255 - (i % 255));
    }
  }
}


//simple test pattern that uses a value from the heat camera to chaneg the color of the circle
class TonyTest implements Pattern {

  int i;

  void setup() {
    colorMode(HSB);
    println("In tony test");
    i = 0;
  }
  void cleanup() {
  }

  void draw() {
    background(100, 100, 100);
    // i = (i + heatVal) % 360;
    fill(100, 100, 100);
    //fill(color(heatVal, 255, 255));
    ellipse(width / 2, height / 2, 150, 150);
  }
}

//take XY from phone screen and draw on Ray
class XYControlDraw implements Pattern {

  ArrayList<PVector> points;

  void setup() {
    colorMode(HSB);
    println("In XYControl Draw");
    oscHandlerQueue.enable();
    println("OCS handler enable: " + oscHandlerQueue.isAvalible());
    points = new ArrayList<PVector>();
  }
  void cleanup() {
  }

  void draw() {
    background(100, 100, 100);
    if ( oscHandlerQueue.isAvalible()) {
      PVector p = oscHandlerQueue.pop();
      p.x =map(p.x, 0, 100, 0, width);
      p.y =map(p.y, 0, 100, 0, height);
      points.add(p);
    }

    int i = 0;
    for (PVector p : points) {
      fill(i % 360, 100, 100);
      ellipse(p.x, p.y, 5, 5);
      i+= 5;
    }
  }
}




//take XY from phone screen and draw on Ray
class XYControlDot implements Pattern {
  ArrayList<PVector> points;
  void setup() {
    colorMode(HSB);
    println("In XYControlDot");
  }
  void cleanup() {
  }
  void draw() {
    background(100, 100, 100);
    fill(30, 100, 100);
    ellipse(map(xControl, 0, 100, 0, width), map(yControl, 0, 100, 0, height), 10, 10);
  }
}

class Diamonds implements Pattern {

  PVector center;
  int inc;

  void setup() {
    colorMode(HSB);
    println("In Diamond");
    center = new PVector(width / 2, height / 2);
    inc = 1;
    rectMode(CENTER);
  }
  void cleanup() {
  }

  void draw() {
    inc++;
    pushMatrix();
    translate(center.x, center.y);
    rotate(PI / 4);
    for ( int i = width; i > 0; i--) {
      fill((inc + i ) % 360, 100, 100);
      stroke((inc + i ) % 360, 100, 100);
      rect( 0, 0, i, i);
      //print(center.x + " " + center.y);
    }
    popMatrix();
  }
}

//something about being orange
class NickySpecial implements Pattern {

  int i;
  int startSize;

  void setup() {
    colorMode(HSB, 360, 255, 255);
    noStroke();
    println("In NickySpecial");
    i = 0;
    startSize = 50;
  }
  void cleanup() {
  }

  void draw() {
    i = (i + 1) % 360;
    background(0);
    fill(i, 255, 255);
    ellipse(width / 2, height / 2, startSize + i, startSize + i);
  }
}


class SpiralHue implements Pattern {

  float rotateValue;
  int[] cords;
  Timer timer;
  Timer timer2;
  int colorOffSet;

  void setup() {
    background(0, 0, 0);
    colorMode(HSB);

    rotateValue = 0;
    colorOffSet = 0;

    timer = new Timer(10);
    timer2 = new Timer(200);

    cords = new int[360];
    for (int i = 0; i < cords.length; i++) {
      cords[i] = i;
    }
  }
  void cleanup() {
  }

  void draw() {
    background(0, 0, 0);

    if (timer.check() == true) {
      rotateValue += .01;
      //colorOffSet = ++colorOffSet % cords.length;
      //println(colorOffSet + " ");
    }

    if (timer2.check() == true) {
      colorOffSet = (colorOffSet + 10)% cords.length;
    }
    translate(width / 2, height / 2);
    //rotate(PI/180 * rotateValue);
    //print(PI/180 * rotateValue + " ");
    ellipse(0, 0, 5, 5);
    //print("start ");
    for (int i = 0; i < cords.length; i++) {
      int hueFill = (i + colorOffSet) % cords.length;
      //print(hueFill + " ");


      fill(int(map(hueFill, 0, cords.length, 0, 360)), 360, 360);
      stroke(int(map(hueFill, 0, cords.length, 0, 360)), 360, 360);

      rotate(PI/180 * rotateValue);
      ellipse(0, i/4, 1, 1);
    }
  }
}



class Wigg implements Pattern {

  ArrayList<Wiggler> wiggles;
  int numWigs;


  void setup() {
    colorMode(RGB);
    numWigs = 7;


    wiggles = new ArrayList<Wiggler>();

    //for (int i = 0; i < numWigs; i++){
    //  wiggles.add(new Wiggler(height / 2, width / 2, i * 15, (360 / numWigs) * i));
    //}

    wiggles.add(new Wiggler(height / 2, width / 2, 105, (255 / 7 ) * 0));
    wiggles.add(new Wiggler(height / 2, width / 2, 90, (255 / 7 ) * 1));
    wiggles.add(new Wiggler(height / 2, width / 2, 75, (255 / 7 ) * 2));
    wiggles.add(new Wiggler(height / 2, width / 2, 60, (255 / 7 ) * 3));
    wiggles.add(new Wiggler(height / 2, width / 2, 45, (255 / 7 ) * 4));
    wiggles.add(new Wiggler(height / 2, width / 2, 30, (255 / 7 ) * 5));
    wiggles.add(new Wiggler(height / 2, width / 2, 15, (255 / 7 ) * 6));
    
    println("In wiggle");
  }

  void cleanup() {
  }

  void draw() {
    background(0);
    for ( Wiggler w : wiggles) {
      w.wiggle();
      w.display();
    }
  }
}


// An object that wraps the PShape

class Wiggler {

  // The PShape to be "wiggled"
  PShape s;
  // Its location
  float x, y;
  int rad;
  int hue;

  Colormap cm;
  // For 2D Perlin noise
  float yoff = 0;


  // We are using an ArrayList to keep a duplicate copy
  // of vertices original locations.
  ArrayList<PVector> original;

  Wiggler(int x, int y, int rad, int hue) {
    this. x = y;
    this.y = x; 
    this.rad = rad;
    this.hue = hue;

    cm = getColormap("hsi");
    // The "original" locations of the vertices make up a circle
    original = new ArrayList<PVector>();
    for (float a = 0; a < TWO_PI; a+=0.2) {
      PVector v = PVector.fromAngle(a);
      v.mult(rad);
      original.add(v);
    }

    // Now make the PShape with those vertices
    s = createShape();
    s.beginShape();
    s.fill(cm.getColor(hue));
    s.stroke(0);
    s.strokeWeight(2);
    for (PVector v : original) {
      s.vertex(v.x, v.y);
    }
    s.endShape(CLOSE);
  }

  void wiggle() {
    float xoff = 0;

    hue++;

    s.setFill(cm.getColor(hue));
    // Apply an offset to each vertex

    for (int i = 0; i < s.getVertexCount(); i++) {
      // Calculate a new vertex location based on noise around "original" location
      PVector pos = original.get(i);
      float a = TWO_PI*noise(xoff, yoff);
      PVector r = PVector.fromAngle(a);

      r.mult(4);
      r.add(pos);
      // Set the location of each vertex to the new one
      s.setVertex(i, r.x, r.y);
      // increment perlin noise x value
      xoff+= 0.5;
    }
    // Increment perlin noise y value
    yoff += 0.02;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    shape(s);
    popMatrix();
  }
}
