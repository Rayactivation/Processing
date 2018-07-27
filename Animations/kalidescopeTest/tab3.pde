PImage flipImage(PImage img) {
  PImage newImage = createImage(img.width, img.height, ARGB);
  img.loadPixels();
  newImage.loadPixels();
  int ln = img.pixels.length;
  int n = ln - 1;
  for (int i = 0; i < img.height; i++) {
    for (int j = 0; j < img.width; j++) {
      int newIndex = (img.width - 1) - j;
      int flippedIndex = newIndex + (i * img.width);
      int sourceIndex = j + (i * img.width);
      newImage.pixels[flippedIndex] = img.pixels[sourceIndex];
    }
  }
  newImage.updatePixels();
  return newImage;
}


PGraphics makeShapes() {
  next.beginDraw();
  next.colorMode(HSB, 360, 100, 100, 100);
  next.rectMode(CENTER);
  //next.noStroke();
  next.strokeWeight(.5);
  next.stroke(180, 50);
  next.background(sGen.h, 100, 100);
  sGen.run();
  next.endDraw();
  return next;
}

void drawHex() {
  fill(0);
  stroke(360);
  strokeWeight(5);
  beginShape();
  for (int i = 0; i < 6; i++) {
    float x = width/2 + cos(i*PI/3) * 210;
    float y = height/2+ sin(i*PI/3) * 210;
    vertex(x, y);
  }
  endShape(CLOSE);
}

void overlay() {
  stroke(0, 20);
  strokeWeight(.5);
  line(width/2, height/2-180, width/2, height/2+180);
  for (int i = 0; i < 12; i++) {
    float x = width/2 + cos(i*PI/3) * 205;
    float y = height/2+ sin(i*PI/3) * 205;
    line(x, y, width/2, height/2);
  }
}
