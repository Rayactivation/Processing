OPC opc1;
OPC opc2;
OPC opc3;
OPC opc4;

int rayCanvasWidth = 500;
int rayCanvasHeight = 250;

void setup() {
  size(1000, 500);
  background(0);

  rect(width/2 - rayCanvasWidth / 2, height / 2 - rayCanvasHeight / 2, rayCanvasWidth, rayCanvasHeight);

  opc1 = new OPC(this, "10.0.0.30", 7890);
  opc2 = new OPC(this, "10.0.0.31", 7890);
  opc3 = new OPC(this, "10.0.0.32", 7890);
  opc4 = new OPC(this, "10.0.0.33", 7890);

  int vertSpacing = 40;
  int vertOffSet = 200;

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
  rect(width/2 - rayCanvasWidth / 2, height / 2 - rayCanvasHeight / 2, rayCanvasWidth, rayCanvasHeight);

  println(mouseX, mouseY);
}
