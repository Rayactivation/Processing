//OSC support

Pattern currentPattern;
int nextPatternTime;
ArrayList<Class> patternClasses;

Boolean PROD = false;

void setup() {
  frameRate(30);
  size(800, 600);
  colorMode(HSB, 360, 100, 100);  
  background(0);

  try {
    // TODO: read this in from a command line argument
    if (PROD) {
      ArrayList<OPC> opcs = setupOpc("/Users/jobevers/projects/rayactivation/Processing/layout/layout.json", 80);
    } else {
      ArrayList<OPC> opcs = setupOpc("/Users/jobevers/projects/rayactivation/Processing/layout/dev_layout.json", null);
    }
  }
  catch (IOException e) {
    print("File not found");
    exit();
  }

  patternClasses = new ArrayList<Class>();
  patternClasses.add(PatternA.class);
  patternClasses.add(PatternB.class);

  //OSC setup
  oscSetup();
}

void draw() {
  background(255);
  // Every 30 seconds, pick a new pattern
  if (millis() >= nextPatternTime) {
    nextPatternTime = millis() + 30000;
    currentPattern = newPattern();
    currentPattern.setup();
  }
  int startTime = millis();
  currentPattern.draw();
  int endTime = millis();

  if ((endTime - startTime) > (1000.0 / frameRate)) {
    print("Draw took too long: " + (endTime - startTime));
  }
}


Pattern newPattern() {
  int idx = int(random(0, patternClasses.size()));
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
  Class<?> sketchClass = Class.forName("main");
  Class<?> innerClass = patternClasses.get(idx);

  java.lang.reflect.Constructor constructor = innerClass.getDeclaredConstructor(sketchClass);
  return (Pattern)constructor.newInstance(this);
}
