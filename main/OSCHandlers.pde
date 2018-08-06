/*

OSCHandler space

Handlers for:
- Heat cam
- Animation secection controller
- Ray position informaiton

*/


import oscP5.*;
import netP5.*;
OscP5 oscP5tcpServer;

int oscInputPort = 5000;

void oscSetup(){
   oscP5tcpServer = new OscP5(this, oscInputPort, OscP5.UDP);
}

void oscEvent(OscMessage theMessage) {
  /* in this example, both the server and the client share this oscEvent method */
  System.out.println("### got a message " + theMessage);
  if (theMessage.checkAddrPattern("/test")) {
    println("and it is a test message ");
    theMessage.print();
    println("The first int is " + theMessage.get(0).intValue() + " \nand the second int is " + theMessage.get(1).intValue());
  }
  
  if (theMessage.checkAddrPattern("/1/push1")) {
     println("and it is a test message ");
    theMessage.print();
   // println("The first int is " + theMessage.get(0).intValue() );
 
  }
  
  //place holder pattern check example  - will delete
  //if (theMessage.checkAddrPattern("/camera/0")) {
  //  println("camera message is ");
  //  theMessage.print();
  //  for ( int i = 0; i < 8; i ++) {
  //    //cameraVals[i] = theMessage.get(i % 8).intValue();
  //  }
  //}
  
}
