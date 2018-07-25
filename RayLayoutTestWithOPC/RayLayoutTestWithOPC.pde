OPC opc1;
OPC opc2;
OPC opc3;
OPC opc4;

int rayCanvasWidth = 700;   // 7 meters
int rayCanvasHeight = 400;  // 4 meters

float twoInches = 5.08;
//float ledSpacing = 10/3;    // 30/m  3.33333
//float ledSpacing = 269 / 80;
float ledSpacing = 3.3;


void setup() {
  size(1000, 700);
  background(0);


  opc1 = new OPC(this, "10.0.0.30", 7890);
  opc2 = new OPC(this, "10.0.0.31", 7890);
  opc3 = new OPC(this, "10.0.0.32", 7890);
  opc4 = new OPC(this, "10.0.0.33", 7890);
  
  

  //Setup opc1 - 48 strips in teh left wing
  for (int i = 0; i < 48; i ++) {
    opc1.ledStrip(i, 80, (307 / 2) + (300 / 2) - 17, (i * twoInches) + 150, ledSpacing, 0, true);
  }

  //Setup opc2 - 
  for (int i = 0; i < 8; i ++) {
    opc2.ledStrip(i, 80, (307 / 2) + (300 / 2) - 17, i * twoInches + (twoInches * 48) + 150, ledSpacing, 0, true);
  }

  //setup opc3 - 48 strips in the right wing
  for (int i = 0; i < 48; i ++) {
    opc3.ledStrip(i, 80, ( 365 + 307 / 2) + (300 / 2) - 20, (i * twoInches) + 150, ledSpacing, 0, false);
  }

  //setup opc 4
  for (int i = 0; i < 8; i ++) {
    opc4.ledStrip(i, 80, ( 365 + 307 / 2) + (300 / 2) - 20, i * twoInches + (twoInches * 48) + 150, ledSpacing, 0, false);
  }

  //opc1.ledStrip(0, 32, width/2, 0 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc1.ledStrip(1, 32, width/2, 1 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc2.ledStrip(0, 32, width/2, 2 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc2.ledStrip(1, 32, width/2, 3 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc3.ledStrip(0, 32, width/2, 4 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc3.ledStrip(1, 32, width/2, 5 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc4.ledStrip(0, 32, width/2, 6 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  //opc4.ledStrip(1, 32, width/2, 7 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
}


void draw() {
  background(255, 0, 0);

  //fill(0, 0, 0);
  // rect(width/2 - rayCanvasWidth / 2, height / 2 - rayCanvasHeight / 2, rayCanvasWidth, rayCanvasHeight);
  drawRayShape();
  println(mouseX, mouseY);

  fill(255, 255, 0);
  ellipse(mouseX, mouseY, 15, 15);
}

void drawRayShape() {
  pushMatrix();

  translate(150, 150);
  fill(0, 0, 0);
  rect(0, 0, 634, 400);
  fill(0, 255, 0);
  triangle(269, 0, 269, 307, 0, 165);
  fill(0, 0, 255);
  triangle(365, 0, 634, 165, 365, 307);
  fill(255, 0, 0);
  rect(269, 0, 365 - 269, 0 + 307); 

  popMatrix();
}
