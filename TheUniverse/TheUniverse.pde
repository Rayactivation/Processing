OPC opc1;
OPC opc2;
OPC opc3;
OPC opc4;

int rayCanvasWidth = 500;
int rayCanvasHeight = 250;

float[][][] colours = new float[300][300][3];

void setup() {
  size(300, 300);
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

  for (int i = 0; i < width; i++) 
  {
    for (int j = 0; j < height; j++) 
    {
      for (int k = 0; k < 3; k++) 
      {
        colours[i][j][k] = 0;
      }
    }
  }
  colorMode(HSB);
  frameRate(24);
}


void draw() {
  //background(0);
  //rect(width/2 - rayCanvasWidth / 2, height / 2 - rayCanvasHeight / 2, rayCanvasWidth, rayCanvasHeight);

  //println(mouseX, mouseY);

  loadPixels();
  for (int j = 1; j < height - 1; j++) 
  {
    for (int i = 1; i < width - 1; i++) 
    {
      int newij;
      int randcol = floor(random(0, 3));
      if ((randcol == 0) || (randcol == 2)) 
      {
         newij = int(colours[i][j][randcol]*0.97);
      } else {
         newij = floor(colours[i][j][randcol]*0.97);
      }
      int randdir = floor(random(1, 5));       
      switch (randdir) 
      {
      case 1: 
        colours[i][j][randcol] = newij;
        colours[i-1][j][randcol] = max(colours[i-1][j][randcol], newij);     
      case 2: 
        colours[i][j][randcol] = newij;
        colours[i+1][j][randcol] = max(colours[i+1][j][randcol], newij);
      case 3: 
        colours[i][j][randcol] = newij;
        colours[i][j-1][randcol] = max(colours[i][j-1][randcol], newij);
      case 4: 
        colours[i][j][randcol] = newij;
        colours[i][j+1][randcol] = max(colours[i][j+1][randcol], newij);
      }

      pixels[j*width + i] = color(colours[i][j][0], colours[i][j][1], colours[i][j][2]);
    }
  }  
  updatePixels();

  if (mousePressed) 
  {
    colours[mouseX][mouseY][0] = random(0, 100);
    colours[mouseX][mouseY][1] = 1000;
    colours[mouseX][mouseY][2] = 1000;
  }
}
