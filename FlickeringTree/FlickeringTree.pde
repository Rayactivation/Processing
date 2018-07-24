OPC opc1;
OPC opc2;
OPC opc3;
OPC opc4;

int rayCanvasWidth = 500;
int rayCanvasHeight = 250;

pathfinder[] paths;
int num;
static int count;

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

  background(250);
  ellipseMode(CENTER);
  stroke(200, 0, 0, 200);
  smooth();
  num = 2;
  count = 0;
  paths = new pathfinder[num];
  for (int i = 0; i < num; i++) paths[i] = new pathfinder();
}


void draw() {
  // background(0);
  // rect(width/2 - rayCanvasWidth / 2, height / 2 - rayCanvasHeight / 2, rayCanvasWidth, rayCanvasHeight);

  println(mouseX, mouseY);

  for (int i = 0; i < paths.length; i++) {
    PVector loc = paths[i].location;
    PVector lastLoc = paths[i].lastLocation;
    strokeWeight(paths[i].diameter);
    line(lastLoc.x, lastLoc.y, loc.x, loc.y);
    paths[i].update();
  }
}

/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/144159*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
class pathfinder {
  PVector lastLocation;
  PVector location;
  PVector velocity;
  float diameter;
  boolean isFinished;
  pathfinder() {
    location = new PVector(width/2, height);
    lastLocation = new PVector(location.x, location.y);
    velocity = new PVector(0, -10);
    diameter = random(10, 20);
    isFinished = false;
  }
  pathfinder(pathfinder parent) {
    location = parent.location.get();
    lastLocation = parent.lastLocation.get();
    velocity = parent.velocity.get();
    diameter = parent.diameter * 0.62;
    isFinished = parent.isFinished;
    parent.diameter = diameter;
  }
  void update() {

    if (location.x > -10 & location.x < width + 10 & location.y > -10 & location.y < height + 10) {
      lastLocation.set(location.x, location.y);
      if (diameter > 0.2) {
        count ++;
        PVector bump = new PVector(random(-1, 1), random(-1, 1));
        velocity.normalize();
        bump.mult(0.2);
        velocity.mult(0.8);
        velocity.add(bump);
        velocity.mult(random(5, 10));
        location.add(velocity);
        if (random(0, 1) < 0.2) { // control length
          paths = (pathfinder[]) append(paths, new pathfinder(this));
        }
      } else {
        if (!isFinished) {
          isFinished = true;
          noStroke();
          fill(240, 230, 150, 100);
          ellipse(location.x, location.y, 10, 10);
          stroke(200, 0, 0, 200);
        }
      }
    }
  }
}
void mousePressed() {
  background(250);
  count = 0;
  paths = new pathfinder[num];
  for (int i = 0; i < num; i++) paths[i] = new pathfinder();
}
