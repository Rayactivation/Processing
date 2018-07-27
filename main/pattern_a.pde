// Patterns defined in tabs must be static, or be in a .java file
// https://github.com/processing/processing/issues/3446#issuecomment-117616074//
class PatternA implements Pattern {
  void setup(){}
  
  
  void draw(){
    if (frameCount % 100 == 0) {
      print("DRAW PATTERN A");
    }
  }
}
