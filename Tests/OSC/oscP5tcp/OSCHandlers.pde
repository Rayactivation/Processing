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
