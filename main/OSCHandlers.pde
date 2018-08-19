/*
 OSCHandler space

 Handlers for:
 - Heat cam - done, you get an int of all the pixels over a temp threshold
 - Animation secection controller - done, cycles next animation
 - Ray position informaiton
 - Paramater tweaking
 -heat came threshold
 */

import oscP5.*;
import netP5.*;
import java.util.ArrayDeque;
OscP5 oscP5tcpServer;

int oscInputPort = 5000;

//these are global and are declared here
static int heatVal = 0;
static int xControl, yControl = 0;
static int thermoVal = 0;
// We get an OSC message every time the ray
// makes a rotation and passes a spot.
static int lastRotationTime;
// rotationSpeed is how long it took us
// to make the last rotation
// in radians / ms
static float rotationSpeed;
// how long it took to make the last rotation
// in milliseconds
static float lastRotationDuration;



void oscSetup() {
  oscP5tcpServer = new OscP5(this, oscInputPort, OscP5.UDP);
}

int timeSinceLastRotation() {
  return millis() - lastRotationTime;
}

float currentRotationLocation() {
  return rotationSpeed * timeSinceLastRotation();
}

void oscEvent(OscMessage theMessage) {
  if (theMessage.checkAddrPattern("/rotation")) {
    int now = millis();
    lastRotationDuration = now - lastRotationTime;
    rotationSpeed = 2*PI / lastRotationDuration;
    lastRotationTime = now;
  }

  //heat cam listener
  if (theMessage.checkAddrPattern("/cameraHeatVal")) {
    println("Heat Val is " + theMessage.get(0).intValue());
    heatVal =  theMessage.get(0).intValue();
  }

  //position handler


  //tempeature handler
  if (theMessage.checkAddrPattern("/cameraHeatVal")) {
    //theMessage.print();
    thermoVal = theMessage.get(0).intValue();
    println("new heatval: " + thermoVal);
  }

  //controller handler - from my phone with custom touch OSC layout
  if (theMessage.checkAddrPattern("/control/nextAnimation")) {
    //theMessage.print();
    if ( theMessage.get(0).floatValue() == 0) {
      println("Next animation ");
      nextPattern();
    }
  }

  //controller handler - from my phone with custom touch OSC layout
  if (theMessage.checkAddrPattern("/control/touch")) {
    //theMessage.print();
    xControl = int(theMessage.get(0).floatValue() * 100);
    yControl = int(theMessage.get(1).floatValue() * 100);
    //println( xControl + " " + yControl);
    if (oscHandlerQueue.isEnabled() == true) {
      oscHandlerQueue.push(xControl, yControl);
    }
  }


  //suprise handler
}


class OscHandlerQueue {

  ArrayList<PVector> queue;

  boolean enabled;

  OscHandlerQueue() {
  }

  void newQueue() {
    enabled = false;
    queue = new ArrayList<PVector>();
    println("New OscQueue");
  }

  void enable() {
    enabled = true;
    //    println("OscQueue enabled");
  }

  void push(int x, int y) {
    queue.add(new PVector(x, y));
    println("Adding to OscQueue");
  }

  boolean isEnabled() {
    return enabled;
  }

  boolean isAvalible() {
    return ( queue.size() == 0  ? false : true);
  }

  PVector pop() {
    PVector p = queue.get(0);
    queue.remove(0);
    return p;
  }
}

// Calculates the average over the last N milliseconds
class MovingAverageTime {
  int period;
  ArrayDeque<Pair<Integer, Float>> points;
  float currentEstimate;

  MovingAverageTime(int period) {
    this.period = period;
    points = new ArrayDeque<Pair<Integer, Float>>();
  }

  float update(float point) {
    int now = millis();
    float currentTotal = currentEstimate * points.size();
    points.push(new Pair<Integer, Float>(now, point));
    int cutoff = now - period;
    println("cutoff:", cutoff);
    // guaranteed to have at least have one item in the array
    // so I'm not going to check if its empty
    float removedSum = 0;
    while (true) {
      Pair<Integer, Float> pt =  points.peekLast();
      println("pt time:", pt.getValue0(), cutoff);
      if (pt.getValue0() >= cutoff) {
        break;
      }
      removedSum += pt.getValue1();
      points.removeLast();
    }
    float total = currentTotal - removedSum + point;
    currentEstimate = total / points.size();
    return currentEstimate;
  }
}
