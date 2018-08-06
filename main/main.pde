//OSC support

Pattern currentPattern;
int nextPatternTime;
ArrayList<Class> patternClasses;

void setup() {
  frameRate(30);
  size(128, 128);
  colorMode(HSB, 360, 100, 100, 100);
  patternClasses = new ArrayList<Class>();
  patternClasses.add(PatternA.class);
  patternClasses.add(PatternB.class);

  //OSC setup
  oscSetup();

  //OPC setup
  opcSetup();
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
  try {
    // These piece of wonderful magic is from:
    // https://stackoverflow.com/a/31184583
    Class<?> sketchClass = Class.forName("main");
    Class<?> innerClass = patternClasses.get(idx);

    java.lang.reflect.Constructor constructor = innerClass.getDeclaredConstructor(sketchClass);
    Pattern u = (Pattern)constructor.newInstance(this);
    println(u.toString());
    return u;
  }
  catch(Exception e) {
    e.printStackTrace();
    return newPattern();
  }

  //  Pattern result = clazz.newInstance();
  //  print("IT WORKED");
  //  return result;
  //}
  //catch (InstantiationException ex) {
  //  print("Failed to Instantiate");
  //  return newPattern();
  //} catch (IllegalAccessException ex) {
  //  print("IllegalAccess");
  //  return newPattern();
  //}
}
