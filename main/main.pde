// These values are set in the data/config.txt file
//
// If true, patterns are picked randomly, otherwise they go in sequence
boolean randomPattern;
// The full path to the layout file
String layoutFile;
// In production, this need to be 80, generally null for development
Integer stripSize = null;
// How long each pattern runs for, in milliseconds
int patternSwitchTime;

boolean showLocations = false;


Pattern currentPattern;
int nextPatternTime = 0;
ArrayList<Class> patternClasses;
int currentPatternIdx = -1;


void setup() {
  frameRate(30);
  size(216, 144);
  //size(800, 600);
  // TODO(JIE): I think that we should use RGB and colormaps
  colorMode(HSB, 360, 100, 100);  
  background(0);

  configure();

  try {
    ArrayList<OPC> opcs = setupOpc(layoutFile, stripSize);
    for (OPC opc : opcs) {
      opc.showLocations(true);
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
  patternClasses.add(XYControlDot.class);


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
  int startTime = millis();
  nextPatternTime = millis() + patternSwitchTime;
  currentPattern = newPattern();
  currentPattern.setup();
  int endTime = millis();
  println("Took " + (endTime - startTime) + " milliseconds to switch patterns");
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
    if (randomPattern) {
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
