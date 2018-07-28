/**
 * oscP5tcp by andreas schlegel
 * example shows how to use the TCP protocol with oscP5.
 * what is TCP? http://en.wikipedia.org/wiki/Transmission_Control_Protocol
 * in this example both, a server and a client are used. typically 
 * this doesnt make sense as you usually wouldnt communicate with yourself
 * over a network. therefore this example is only to make it easier to 
 * explain the concept of using tcp with oscP5.
 * oscP5 website at http://www.sojamo.de/oscP5
 */

import oscP5.*;
import netP5.*;

int cameraVals[];


OscP5 oscP5tcpServer;

OscP5 oscP5tcpClient;

NetAddress myServerAddress;

void setup() {
  /* create  an oscP5 instance using TCP listening @ port 11000 */
  oscP5tcpServer = new OscP5(this, 5000, OscP5.UDP);
  
  /* create an oscP5 instance using TCP. 
   * the remote address is 127.0.0.1 @ port 11000 = the server from above
   */
  //oscP5tcpClient = new OscP5(this, "127.0.0.1", 5000, OscP5.TCP);
  
  cameraVals = new int[64];
}


void draw() {
  background(0);  
}




void keyPressed() {
  /* check how many clients are connected to the server. */
  println(oscP5tcpServer.tcpServer().getClients().length);
}

void oscEvent(OscMessage theMessage) {
  /* in this example, both the server and the client share this oscEvent method */
  System.out.println("### got a message " + theMessage);
  if(theMessage.checkAddrPattern("/test")) {
    println("and it is a test message ");
    theMessage.print();
  println("The first int is " + theMessage.get(0).intValue() + " \nand the second int is " + theMessage.get(1).intValue());

  }
  if(theMessage.checkAddrPattern("/camera/0")) {
    println("camera message is ");
    theMessage.print();
    for ( int i = 0; i < 8; i ++){
      cameraVals[i] = theMessage.get(i % 8).intValue();
    }
    //println(cameraVals);
  }
    if(theMessage.checkAddrPattern("/camera/1")) {
    println("camera message is ");
    theMessage.print();
    for ( int i = 8; i < 16; i ++){
      cameraVals[i] = theMessage.get(i % 8).intValue();
    }
    //println(cameraVals);
  }
    if(theMessage.checkAddrPattern("/camera/2")) {
    println("camera message is ");
    theMessage.print();
    for ( int i = 16; i < 24; i ++){
      cameraVals[i] = theMessage.get(i % 8).intValue();
    }
    //println(cameraVals);
  }
    if(theMessage.checkAddrPattern("/camera/3")) {
    println("camera message is ");
    theMessage.print();
    for ( int i = 24; i < 32; i ++){
      cameraVals[i] = theMessage.get(i % 8).intValue();
    }
    //println(cameraVals);
  }
    if(theMessage.checkAddrPattern("/camera/4")) {
    println("camera message is ");
    theMessage.print();
    for ( int i = 32; i < 40; i ++){
      cameraVals[i] = theMessage.get(i % 8).intValue();
    }
    //println(cameraVals);
  }
    if(theMessage.checkAddrPattern("/camera/5")) {
    println("camera message is ");
    theMessage.print();
    for ( int i = 40; i < 48; i ++){
      cameraVals[i] = theMessage.get(i % 8).intValue();
    }
    //println(cameraVals);
  }
    if(theMessage.checkAddrPattern("/camera/6")) {
    println("camera message is ");
    theMessage.print();
    for ( int i = 48; i < 56; i ++){
      cameraVals[i] = theMessage.get(i % 8).intValue();
    }
    //println(cameraVals);
  }
    if(theMessage.checkAddrPattern("/camera/7")) {
    println("camera message is ");
    theMessage.print();
    for ( int i = 56; i < 64; i ++){
      cameraVals[i] = theMessage.get(i % 8).intValue();
    }
    println(cameraVals);
  }
}
