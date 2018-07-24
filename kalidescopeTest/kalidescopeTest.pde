// Left mouse to toggle  between rect or ellipse particles.
// Right mouse to toggle rotation/roll of particles.
// Kaleidoscope structure from "Kaleidoscope" by Jeremy English, sketch #30186.
// boolean, PGraphics, PImage, class, function, translate, rotate, particle system
// PVector, pixels, ArrayList, frameCount, color, random, kaleidoscope

shapeGen  sGen;
PGraphics  sourcePG, next;
Triangle tri;
boolean isRect, rtt;

OPC opc1;
OPC opc2;
OPC opc3;
OPC opc4;

void setup() {
  frameRate(30);
  size(700, 600);
  colorMode(HSB, 360, 100, 100, 100);
  tri = new Triangle();
  sGen = new shapeGen();
  sourcePG = createGraphics(100, 173);
  next = createGraphics(100, 173);
  isRect = false;
  rtt = true;

  int vertSpacing = 80;
  int vertOffSet = 250;

  opc1 = new OPC(this, "10.0.0.30", 7890);
  opc2 = new OPC(this, "10.0.0.31", 7890);
  opc3 = new OPC(this, "10.0.0.32", 7890);
  opc4 = new OPC(this, "10.0.0.33", 7890);

  opc1.ledStrip(0, 32, width/2, 0 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc1.ledStrip(1, 32, width/2, 1 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc2.ledStrip(0, 32, width/2, 2 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc2.ledStrip(1, 32, width/2, 3 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc3.ledStrip(0, 32, width/2, 4 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc3.ledStrip(1, 32, width/2, 5 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc4.ledStrip(0, 32, width/2, 6 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc4.ledStrip(1, 32, width/2, 7 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
}


void draw() {
  background(0);
  drawHex();
  sourcePG = makeShapes(); // make PGraphic from moving particles
  tri.clipSourcePG(); // clip tri from sourcePG
  float theta = 0;
  for (int i = 0; i < 6; i++) {
    pushMatrix();
    translate(width/2, height/2);
    rotate(theta);
    tri.drawImgTri(); // draw clipped tri collected by clipSourcePG
    PImage img = flipImage(tri.clippedImg); // then flip
    image(img, -100, 0); // and draw flipped img
    popMatrix();
    theta += PI/3;
  }
  overlay();
}

void mousePressed() {
  if (mouseButton == LEFT) isRect = !isRect;
  if (mouseButton == RIGHT) rtt = !rtt;
}
