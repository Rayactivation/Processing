

void setup() {
  size(1000, 500);
  background(0);

  int rayCanvasWidth = 500;
  int rayCanvasHeight = 250;

  rect(width/2 - rayCanvasWidth / 2, height / 2 - rayCanvasHeight / 2, rayCanvasWidth, rayCanvasHeight);
}


void draw() {
  println(mouseX, mouseY);

}
