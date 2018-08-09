//OSC support

Pattern currentPattern;
int nextPatternTime = 0;
ArrayList<Class> patternClasses;
final int patternSwitchTime = 5000;

Boolean PROD = true;
// set to null to pick a random pattern, otherwise this pattern will be picked each time
Integer PATTERN = 0;



void setup() {
  frameRate(30);
  size(216, 144);
  //size(800, 600);
  colorMode(HSB, 360, 100, 100);  
  background(0);

  try {
    // TODO: read this in from a command line argument
    ArrayList<OPC> opcs;
    if (PROD) {
      //  opcs = setupOpc("/Users/jobevers/projects/rayactivation/Processing/layout/layout.json", 80);
      //opcs = setupOpc("/home/tony/projects/RayRepos/Processing/layout/layout.json", 80);
      opcs = setupOpc("/home/master/RayRepos/Processing/layout/layout.json", 80);
    } else {
      //opcs = setupOpc("/Users/jobevers/projects/rayactivation/Processing/layout/dev_layout.json", null);
      //opcs = setupOpc("/home/tony/projects/RayRepos/Processing/layout/dev_layout.json", null);
      opcs = setupOpc("/home/master/RayRepos/Processing/layout/dev_layout.json", null);
    }
    for (OPC opc : opcs) {
      opc.showLocations(true);
    }
  }
  catch (IOException e) {
    print("File not found");
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
  patternClasses.add(PatternA.class);
  patternClasses.add(PatternB.class);

  println("patternClasses size is " + patternClasses.size());

  //OSC setup
  oscSetup();
}

void draw() {
  background(255);
  // Every 30 seconds, pick a new pattern
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
  //println("patternClasses size is " + patternClasses.size());
  int idx;
  if (PATTERN == null) {
    idx = int(random( patternClasses.size()));
    println("idx is " + idx);
  } else {
    idx = (PATTERN + 1) % patternClasses.size();
    println("idx is " + idx);
  }
  println("\nSelect new pattern", idx);
  try {
    return constructNewPattern(idx);
  }
  catch(Exception e) {
    e.printStackTrace();
    return newPattern();
  }
}

Pattern constructNewPattern(int idx) throws Exception {
  // This piece of wonderful magic is from:
  // https://stackoverflow.com/a/31184583
  PATTERN = idx;
  Class<?> sketchClass = Class.forName("main");
  Class<?> innerClass = patternClasses.get(idx);

  java.lang.reflect.Constructor constructor = innerClass.getDeclaredConstructor(sketchClass);
  return (Pattern)constructor.newInstance(this);
}
