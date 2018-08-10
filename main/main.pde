boolean PROD = false;
// set to true to pick a random pattern, otherwise patterns will be picked sequentially
boolean RANDOM_PATTERN;
boolean DEBUG;

Pattern currentPattern;
int nextPatternTime = 0;
ArrayList<Class> patternClasses;
int patternSwitchTime;
int currentPatternIdx = -1;

void setup() {
  frameRate(30);
  size(216, 144);
  //size(800, 600);
  colorMode(HSB, 360, 100, 100);  
  background(0);

  if (PROD) {
    RANDOM_PATTERN = true;
    DEBUG = false;
    patternSwitchTime = 30 * 1000; // 30 seconds
  } else {
    RANDOM_PATTERN = false;
    DEBUG = true;
    patternSwitchTime = 5 * 60 * 1000; // five minutes
  }

  try {
    // TODO: read this in from a command line argument
    ArrayList<OPC> opcs;
    if (PROD) {
      //opcs = setupOpc("/Users/jobevers/projects/rayactivation/Processing/layout/layout.json", 80);
      //opcs = setupOpc("/home/tony/projects/RayRepos/Processing/layout/layout.json", 80);
      opcs = setupOpc("/home/master/RayRepos/Processing/layout/layout.json", 80);
    } else {
      opcs = setupOpc("/Users/jobevers/projects/rayactivation/Processing/layout/dev_layout.json", null);
      //opcs = setupOpc("/home/tony/projects/RayRepos/Processing/layout/dev_layout.json", null);
      //opcs = setupOpc("/home/master/RayRepos/Processing/layout/dev_layout.json", null);
    }
    for (OPC opc : opcs) {
      opc.showLocations(false);
    }
  }
  catch (IOException e) {
    println("!!!!! Layout File not found !!!!!!");
    exit();
  }

  // There is no type checking on this, so it won't complain
  // at compile time if your class is not implementing Pattern
  // but it will fail dramatically at runtime.
  // I usually have to restart the processing application when
  // that happens
  patternClasses = new ArrayList<Class>();
  patternClasses.add(ColorEmittingBar.class);
  patternClasses.add(RandomLinearBalls.class);
  patternClasses.add(RandomEbb.class);
  patternClasses.add(TonyTest.class);
  patternClasses.add(NickySpecial.class);
  patternClasses.add(SpiralHue.class);

  //patternClasses.add(PatternA.class);
  //patternClasses.add(PatternB.class);

  println("patternClasses size is " + patternClasses.size());

  //OSC setup
  oscSetup();
}

void draw() {
  background(255);
  if (millis() >= nextPatternTime) {
    nextPattern();
  }
  int startTime = millis();
  currentPattern.draw();
  int endTime = millis();

  float targetRate = 1000.0 / frameRate;
  if ((endTime - startTime) > targetRate) {
    println("Draw took too long: " + (endTime - startTime) + " > " + targetRate);
  }
}

void nextPattern() {
  nextPatternTime = millis() + patternSwitchTime;
  currentPattern = newPattern();
  currentPattern.setup();
}

Pattern newPattern() {
  return newPattern(null);
}

Pattern newPattern(Integer idx) {
  idx = pickNewPattern(idx);
  try {
    return constructNewPattern(idx);
  }
  catch(Exception e) {
    e.printStackTrace();
    return newPattern();
  }
}

int pickNewPattern(Integer idx) {
  println("patternClasses size is " + patternClasses.size());
  if (idx == null) {
    if (RANDOM_PATTERN) {
      idx = int(random(patternClasses.size()));
    } else {
      idx = (currentPatternIdx + 1) % patternClasses.size();
    }
  }
  currentPatternIdx = idx;
  println("\nSelect new pattern", idx);
  return idx;
}

Pattern constructNewPattern(int idx) throws Exception {
  // This piece of wonderful magic is from:
  // https://stackoverflow.com/a/31184583
  Class<?> sketchClass = Class.forName("main");
  Class<?> innerClass = patternClasses.get(idx);

  java.lang.reflect.Constructor constructor = innerClass.getDeclaredConstructor(sketchClass);
  return (Pattern)constructor.newInstance(this);
}
