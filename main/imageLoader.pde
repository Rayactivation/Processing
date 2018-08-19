class ImageLoadStar implements Pattern {
  PImage im;

  void setup() {
    print("In image loader Star");
    try {
      im = loadImage("stars1.jpg");
    }
    catch (Exception e) {
      println("failed to load image");
      e.printStackTrace();
      println("calling next pattern");
      nextPattern();
    }
    delay(100);
  }
  void cleanup() {
  };

  void draw() {
    int imHeight = im.height * width / im.width;

    float speed = 0.001;
    float y = (millis() * -speed) % imHeight;

    // Use two copies of the image, so it seems to repeat infinitely

    image(im, 0, y, width, imHeight);
    image(im, 0, y + imHeight, width, imHeight);
  }
}

class ImageLoadFire implements Pattern {
  PImage im;

  void setup() {
    print("In image loader Fire");
    try {    
      im = loadImage("flames.jpg");
    }
    catch (Exception e) {
      println("failed to load image");
      e.printStackTrace();
      println("calling next pattern");
      nextPattern();
    }
    delay(100);
  }
  void cleanup() {
  };

  void draw() {
    int imHeight = im.height * width / im.width;

    float speed = 0.05;
    float y = (millis() * -speed) % imHeight;

    // Use two copies of the image, so it seems to repeat infinitely  

    image(im, 0, y, width, imHeight);
    image(im, 0, y + imHeight, width, imHeight);
  }
}

class ImageLoadBlueFire extends ImageLoadFire {
  
  
  void draw() {
    super.draw();
    filter(INVERT);
  }
}
