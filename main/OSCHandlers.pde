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
OscP5 oscP5tcpServer;

int oscInputPort = 5000;

//these are global and are delcared here
static int heatVal = 0;
static int xControl, yControl = 0;
static int thermoVal = 0;


void oscSetup() {
  oscP5tcpServer = new OscP5(this, oscInputPort, OscP5.UDP);
}

void oscEvent(OscMessage theMessage) {
  //System.out.println("### got a message " + theMessage);
  //theMessage.print();

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
