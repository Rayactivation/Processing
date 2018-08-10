/*
 OSCHandler space
 
 Handlers for:
 - Heat cam
 - Animation secection controller
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

void oscSetup() {
  oscP5tcpServer = new OscP5(this, oscInputPort, OscP5.UDP);
}

void oscEvent(OscMessage theMessage) {
  System.out.println("### got a message " + theMessage);
  theMessage.print();

  //heat cam listener
  if (theMessage.checkAddrPattern("/cameraHeatVal")) {
    println("Heat Val is " + theMessage.get(0).intValue());
    heatVal =  theMessage.get(0).intValue();
  }

  //position handler


  //tempeature handler


  //controller handler - from my phone with custom touch OSC layout
  if (theMessage.checkAddrPattern("/control/nextAnimation")) {
    //theMessage.print();
    if ( theMessage.get(0).floatValue() == 0) {
      println("Next animation ");
      nextPattern();
    }
  }

  //suprise handler
}





//if (theMessage.checkAddrPattern("/1/push1")) {
//  println("and it is a test message ");
//  // theMessage.print();
//  // println("The first int is " + theMessage.get(0).intValue() );
//}


//if (theMessage.checkAddrPattern("/test")) {
//  println("and it is a test message ");
//  theMessage.print();
//  println("The first int is " + theMessage.get(0).intValue() + " \nand the second int is " + theMessage.get(1).intValue());
//}

//place holder pattern check example  - will delete
//if (theMessage.checkAddrPattern("/camera/0")) {
//  println("camera message is ");
//  theMessage.print();
//  for ( int i = 0; i < 8; i ++) {
//    //cameraVals[i] = theMessage.get(i % 8).intValue();
//  }
//}
