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

//OscP5 oscP5tcpClient;

//NetAddress myServerAddress;

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
