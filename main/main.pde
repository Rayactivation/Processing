//OSC support
import oscP5.*;
import netP5.*;

Pattern currentPattern;
int nextPatternTime;
ArrayList<Class> patternClasses;

OscP5 oscP5tcpServer;

void setup() {
  frameRate(30);
  size(128, 128);
  colorMode(HSB, 360, 100, 100, 100);
  patternClasses = new ArrayList<Class>();
  patternClasses.add(PatternA.class);
  patternClasses.add(PatternB.class);
  
  oscP5tcpServer = new OscP5(this, 5000, OscP5.UDP);
  
}

void draw() {
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
