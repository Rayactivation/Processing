OPC opc1;
OPC opc2;
OPC opc3;
OPC opc4;
PImage im;

void setup()
{
  size(400, 200);

  // Load a sample image
  im = loadImage("flames.jpeg");

  opc1 = new OPC(this, "10.0.0.30", 7890);
  opc2 = new OPC(this, "10.0.0.31", 7890);
  opc3 = new OPC(this, "10.0.0.32", 7890);
  opc4 = new OPC(this, "10.0.0.33", 7890);

  int numStrips = 8;
  int vertSpacing =20;
  int vertOffSet = 100;
  //for ( int i = 0; i < 4; i++) {
  //  opc1.ledStrip(i, 32, width/2, i * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //}

  opc1.ledStrip(0, 32, width/2, 0 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc1.ledStrip(1, 32, width/2, 1 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc2.ledStrip(0, 32, width/2, 2 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc2.ledStrip(1, 32, width/2, 3 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc3.ledStrip(0, 32, width/2, 4 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc3.ledStrip(1, 32, width/2, 5 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc4.ledStrip(0, 32, width/2, 6 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc4.ledStrip(1, 32, width/2, 7 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);


  // Connect to the local instance of fcserver
  //opc1 = new OPC(this, "10.0.0.31", 7890);
  //opc2 = new OPC(this, "10.0.0.32", 7890);

  //int numStrips = 8;
  //int vertSpacing = 40;
  //int vertOffSet = 100;
  //for ( int i = 0; i < 4; i++) {
  //  opc1.ledStrip(i, 32, width/2, i * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //}

  //opc1.ledStrip(0, 32, width/2, 0 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc1.ledStrip(1, 32, width/2, 1 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc1.ledStrip(2, 32, width/2, 2 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc1.ledStrip(3, 32, width/2, 3 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc1.ledStrip(4, 32, width/2, 4 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc1.ledStrip(5, 32, width/2, 5 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc1.ledStrip(6, 32, width/2, 6 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc1.ledStrip(7, 32, width/2, 7 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);

  // Map one 64-LED strip to the center of the window
  //opc1.ledStrip(0, 32, width/2, 0 *  width / 70.0, width / 70.0, 0, false);
  //opc1.ledStrip(1, 32, width/2, 1 * width / 70.0, width / 70.0, 0, false);
  //opc1.ledStrip(2, 32, width/2, 2 *  width / 70.0, width / 70.0, 0, false);
  //opc1.ledStrip(3, 32, width/2, 3 *  width / 70.0, width / 70.0, 0, false);

  //opc1.ledStrip(4, 32, width/2, 4 *  width / 70.0, width / 70.0, 0, false);
  //opc1.ledStrip(5, 32, width/2, 5 *  width / 70.0, width / 70.0, 0, false);
  //opc1.ledStrip(6, 32, width/2, 6 * width / 70.0, width / 70.0, 0, false);
  //opc1.ledStrip(7, 32, width/2, 7 *  width / 70.0, width / 70.0, 0, false);


  //opc1.ledStrip(4, 32, width/2, 5 * height/8, width / 70.0, 0, false);
  //opc1.ledStrip(5, 32, width/2, 6 * height/8, width / 70.0, 0, false);
  //opc1.ledStrip(6, 32, width/2, 7 * height/8, width / 70.0, 0, false);

  //for (int i = 0; i < 3; i++) {
  //  opc1.ledStrip(i, 32, width/2, i * height/65, width / 60.0, 0, false);
  //}
  //for (int i = 0; i < 65; i++) {
  //  opc2.ledStrip(i, 32, width/2, i * height/65, width / 60.0, 0, false);
  //}
  //opc1.showLocations(true);

  // opc2.ledStrip(0, 32, width/2, 3 * height/8, width / 70.0, 0, false);
  //opc2.ledStrip(1, 32, width/2, 4 * height/8, width / 70.0, 0, false);
}

void draw()
{
  // Scale the image so that it matches the width of the window
  int imHeight = im.height * width / im.width;

  // Scroll down slowly, and wrap around
  float speed = 0.05;
  float y = (millis() * -speed) % imHeight;

  // Use two copies of the image, so it seems to repeat infinitely  
  image(im, 0, y, width, imHeight);
  image(im, 0, y + imHeight, width, imHeight);
}
