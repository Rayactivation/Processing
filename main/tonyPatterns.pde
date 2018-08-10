//simple test pattern that uses a value from the heat camera to chaneg the color of the circle
class TonyTest implements Pattern {

  int i;

  void setup() {
    colorMode(HSB);
    println("In tony test");
    i = 0;
  }

  void draw() {
    // i = (i + heatVal) % 360;
    fill(color(heatVal, 255, 255));
    ellipse(width / 2, height / 2, 150, 150);
  }
}

//take XY from phone screen and draw on Ray
class PhoneTest implements Pattern {
  void setup() {    
    colorMode(HSB);
    println("In PhoneTest");
    
  }

  void draw() {

  }
}


//something about being orange
class NickySpecial implements Pattern {

  int i;
  int startSize;

  void setup() {
    colorMode(HSB);
    noStroke();
    println("In NickySpecial");
    i = 0;
    startSize = 50;
  }

  void draw() {
    i = (i + 1) % 360;

    //if ( i > 100) {
    //  i = 0;
    //}
    background(0 );
    fill(sin(i) * 360, 255, 255);
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
