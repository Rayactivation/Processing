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
static int lastRotationDuration;

/**
 * Interacts with the heat detector values
 * to do some basic moving averages and
 * can be used to change patterns
 */
class HeatDetector {
  // Keep track of the heat average over one
  // rotation period.  When this hits a certain
  // Threshold than we want to start showing
  // The main patterns
  MovingAverageTime period;
  // Keep a shorter moving average period
  // This will, hopefully, be able to detect
  // an single person / group.
  // When this goes over a threshold
  // the ray should blink.
  //
  // Could just use the raw heatVal but
  // that seems like it would be noisy.

  MovingAverageTime recent;
  float periodValue;
  float recentValue;

  HeatDetector() {
    period = new MovingAverageTime();
    recent = new MovingAverageTime();
    periodValue = 0;
    recentValue = 0;
  }

  void update(int heatVal) {
    // Memory isn't a concern:
    // Even if the camera is spewing data every miscrosecond
    // that would just be 4 million bytes (4mb). The cpu time
    // involved in that though would probably be too much
    periodValue = period.update(heatVal, lastRotationDuration);
    // 5 is... a parameter that will need to be tuned
    // high enough that random noise won't trigger a flash
    // but low enough that a person will cause a flash.
    // Probably should be about half the time that a person
    // is in the frame of the heat camera?
    recentValue = recent.update(heatVal, 5000);
  }
}

HeatDetector heatDetector;


void oscSetup() {
  oscP5tcpServer = new OscP5(this, oscInputPort, OscP5.UDP);
  // Need to wait until some actual data comes in
  // Could, maybe, start with some estimated values (but I haven't tested that)
  lastRotationTime = -1;
  rotationSpeed = -1;
  lastRotationDuration = -1;
  heatDetector = new HeatDetector();
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
    if (lastRotationTime > 0) {
      lastRotationDuration = now - lastRotationTime;
      rotationSpeed = 2*PI / lastRotationDuration;
    }
    lastRotationTime = now;
    println("WE HAD A ROTATION");
  }

  //heat cam listener
  if (theMessage.checkAddrPattern("/cameraHeatVal")) {
    println("Heat Val is " + theMessage.get(0).intValue());
    heatVal =  theMessage.get(0).intValue();
    heatDetector.update(heatVal);
    println("Period Avg:", heatDetector.periodValue);
    println("Recent Avg:", heatDetector.recentValue);
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
  ArrayDeque<Pair<Integer, Float>> points;
  float currentEstimate;

  MovingAverageTime() {
    points = new ArrayDeque<Pair<Integer, Float>>();
  }

  // Weird things can happen if an earlier call
  // uses a small period and then a later call uses a long
  // period.  The class discards data before `period` so
  // The earlier call will cause data loss and the later call
  // will not be "right"
  // I'm letting the period change because the 
  float update(float point, int period) {
    int now = millis();
    float currentTotal = currentEstimate * points.size();
    points.push(new Pair<Integer, Float>(now, point));
    float removedSum = removeOldPoints(now, period);
    float total = currentTotal - removedSum + point;
    currentEstimate = total / points.size();
    return currentEstimate;
  }

  float removeOldPoints(int now, int period) {
    if (period < 0) {
      return 0;  
    }
    int cutoff = now - period;
    // guaranteed to have at least have one item in the array
    // so I'm not going to check if its empty
    float removedSum = 0;
    while (true) {
      Pair<Integer, Float> pt =  points.peekLast();
      if (pt.getValue0() >= cutoff) {
        break;
      }
      removedSum += pt.getValue1();
      points.removeLast();
    }
    return removedSum;
  }
}
