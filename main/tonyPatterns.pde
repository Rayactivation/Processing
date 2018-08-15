/*

 Pattern Ideas
 Noinput
 - dimonds that progress outward from the center
 -lepord spots

 Input
 -Two controlled ball that explode when they hit



 */


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
    background(100,100,100);
    // i = (i + heatVal) % 360;
    fill(color(heatVal, 255, 255));
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
    background(100,100,100);
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
    background(100,100,100);
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
