OPC opc1;
OPC opc2;
OPC opc3;
OPC opc4;
PImage dot;

void setup()
{
  size(400, 400);

  dot = loadImage("dot.png");

  // Connect to the local instance of fcserver
  opc1 = new OPC(this, "10.0.0.31", 7890);
  opc2 = new OPC(this, "10.0.0.31", 7890);
  opc3 = new OPC(this, "10.0.0.32", 7890);
  opc4 = new OPC(this, "10.0.0.33", 7890);

  int numStrips = 8;
  int vertSpacing = 40;
  int vertOffSet = 100;
  //for ( int i = 0; i < 4; i++) {
  //  opc1.ledStrip(i, 32, width/2, i * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //}
  for (int i = 0; i< 23; i++) {
    opc1.ledStrip(i, 80, width/2, i * height/vertSpacing + vertOffSet, width / 100.0, 0, false);
  }
  //opc1.ledStrip(0, 80, width/2, 0 * height/vertSpacing + vertOffSet, width / 100.0, 0, false);
  //opc1.ledStrip(1, 80, width/2, 1 * height/vertSpacing + vertOffSet, width / 100.0, 0, false);
  //opc1.ledStrip(2, 80, width/2, 2 * height/vertSpacing + vertOffSet, width / 100.0, 0, false);
  //opc1.ledStrip(3, 80, width/2, 3 * height/vertSpacing + vertOffSet, width / 100.0, 0, false);
  //opc1.ledStrip(4, 80, width/2, 4 * height/vertSpacing + vertOffSet, width / 100.0, 0, false);
  //opc1.ledStrip(5, 80, width/2, 5 * height/vertSpacing + vertOffSet, width / 100.0, 0, false);
  //opc1.ledStrip(6, 80, width/2, 6 * height/vertSpacing + vertOffSet, width / 100.0, 0, false);
  //opc1.ledStrip(7, 80, width/2, 1 * height/vertSpacing + vertOffSet, width / 100.0, 0, false);
  //opc1.ledStrip(8, 80, width/2, 0 * height/vertSpacing + vertOffSet, width / 100.0, 0, false);
  //opc1.ledStrip(9, 80, width/2, 1 * height/vertSpacing + vertOffSet, width / 100.0, 0, false);
  //opc1.ledStrip(10, 80, width/2, 0 * height/vertSpacing + vertOffSet, width / 100.0, 0, false);
  //opc1.ledStrip(11, 80, width/2, 1 * height/vertSpacing + vertOffSet, width / 100.0, 0, false);
  //opc1.ledStrip(13, 80, width/2, 0 * height/vertSpacing + vertOffSet, width / 100.0, 0, false);
  //opc1.ledStrip(14, 80, width/2, 1 * height/vertSpacing + vertOffSet, width / 100.0, 0, false);
  //opc1.ledStrip(15, 80, width/2, 0 * height/vertSpacing + vertOffSet, width / 100.0, 0, false);


  //opc2.ledStrip(0, 32, width/2, 2 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc2.ledStrip(1, 32, width/2, 3 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc3.ledStrip(0, 32, width/2, 4 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc3.ledStrip(1, 32, width/2, 5 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc4.ledStrip(0, 32, width/2, 6 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc4.ledStrip(1, 32, width/2, 7 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);

  //opc1.ledStrip(0, 16, width/2, 0 * height/8, width / 70.0, 0, false);
  //opc1.ledStrip(1, 16, width/2, 1 * height/8, width / 70.0, 0, false);
  //opc1.ledStrip(1, 3, width/2, 1 * width / 70.0, width / 70.0, 0, false);
  //opc1.ledStrip(2, 5, width/2, 2 *  width / 70.0, width / 70.0, 0, false);
  //opc1.ledStrip(3, 7, width/2, 3 *  width / 70.0, width / 70.0, 0, false);

  //opc1.ledStrip(4, 9, width/2, 4 *  width / 70.0, width / 70.0, 0, false);
  //opc1.ledStrip(5, 11, width/2, 5 *  width / 70.0, width / 70.0, 0, false);
  //opc1.ledStrip(6, 13, width/2, 6 * width / 70.0, width / 70.0, 0, false);
  //opc1.ledStrip(7, 15, width/2, 7 *  width / 70.0, width / 70.0, 0, false);

  // Map one 64-LED strip to the center of the window
  //opc1.ledStrip(3, 1, width/2, 0 * height/8, width / 70.0, 0, false);
  // opc1.ledStrip(1, 3, width/2, 1 * height/8, width / 70.0, 0, false);
  // opc1.ledStrip(2, 5, width/2, 2 * height/8, width / 70.0, 0, false);
  //opc1.ledStrip(0, 7, width/2, 3 * height/8, width / 70.0, 0, false);

  // opc1.ledStrip(7, 9, width/2, 4 * height/8, width / 70.0, 0, false);
  // opc1.ledStrip(5, 11, width/2, 5 * height/8, width / 70.0, 0, false);
  // opc1.ledStrip(6, 13, width/2, 6 * height/8, width / 70.0, 0, false);
  // opc1.ledStrip(4, 15, width/2, 7 * height/8, width / 70.0, 0, false);

  //opc1.ledStrip(4, 32, width/2, 5 * height/8, width / 70.0, 0, false);
  //opc1.ledStrip(5, 32, width/2, 6 * height/8, width / 70.0, 0, false);
  //opc1.ledStrip(6, 32, width/2, 7 * height/8, width / 70.0, 0, false);
  // Connect to the local instance of fcserver. You can change this line to connect to another computer's fcserver
  //opc1 = new OPC(this, "10.0.0.31", 7890);
  //opc2 = new OPC(this, "127.0.0.1", 7891);

  //for (int i = 0; i < 300; i++) {
  //  opc1.ledStrip(i, 32, width/2, i * height/400, width / 60.0, 0, false);
  //}

  //opc1.ledStrip(0, 1,  width/2,  1 * height/400, width / 60.0, 0, false);
  //opc1.ledStrip(1, 3,  width/2,  2 * height/400, width / 60.0, 0, false);
  //opc1.ledStrip(2, 5,  width/2,  3 * height/400, width / 60.0, 0, false);
  //opc1.ledStrip(3, 6,  width/2,  4 * height/400, width / 60.0, 0, false);
  //opc1.ledStrip(4, 8,  width/2,  5 * height/400, width / 60.0, 0, false);
  //opc1.ledStrip(5, 10, width/2,  6 * height/400, width / 60.0, 0, false);

  //for (int i = 0; i < 65; i++) {
  //  opc2.ledStrip(i, 32, width/2, i * height/65, width / 60.0, 0, false);
  //}
  //opc1.showLocations(false);
}

void draw()
{
  background(0);

  // Change the dot size as a function of time, to make it "throb"
  float dotSize = height * 0.6 * (1.0 + 0.2 * sin(millis() * 0.01));

  // Draw it centered at the mouse location
  image(dot, mouseX - dotSize/2, mouseY - dotSize/2, dotSize, dotSize);
}
