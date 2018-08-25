//
class FourierSeries implements Pattern {
  float[] X_PERIODS = new float[]{0, 0};
  int[] X_RATES = new int[]{20000, 30000};
  int[] X_OFFSET = new int[]{int(random(X_RATES[0])), int(random(X_RATES[1]))};
  float[] Y_PERIODS = new float[]{0, 1};
  int[] Y_RATES = new int[]{20000, 30000};
  int[] Y_OFFSET = new int[]{int(random(Y_RATES[0])), int(random(Y_RATES[1]))};
  int N = X_PERIODS.length * Y_PERIODS.length;
  float offset = 0;
  int hueOffset = 0;
  Colormap cm;

  void setup() {
    size(216, 144);  
    frameRate(30);
    colorMode(RGB, 255, 255, 255);
    this.cm = randomColormap();
    for (int i = 0; i < 65536; ++i) {
      a[i] = sin(i * PI * 2.0 / 65536.0);
    }
  }
  void cleanup(){};

  void draw() {
    for (int i=0; i<X_PERIODS.length; i++) {
      X_PERIODS[i] = 3 * sin((millis()+X_OFFSET[i]) * 2 * PI / X_RATES[i]);
    }
    for (int i=0; i<Y_PERIODS.length; i++) {
      Y_PERIODS[i] = 3 * sin((millis() +Y_OFFSET[i]) * 2 * PI / Y_RATES[i]);
    }
    loadPixels();
    for (int x=0; x<width; x++) {
      for (int y=0; y<height; y++) {
        int colorIdx = hueOffset + int(255 * calculate(x, y, offset));
        pixels[x + y*width] = this.cm.getColor(colorIdx);
      }
    }
    updatePixels();
    offset += 2 / frameRate;
    hueOffset += 45 / frameRate;
  }



  float calculate(float x, float y, float offset) {
    float total = 0;
    int cnt = 0;
    for (float n : X_PERIODS) {
      for (float m : Y_PERIODS) {
        float c_x = approxCos(2*PI*n*x / width);
        float s_x = approxSin(2*PI*n*x / width);
        float c_y = approxCos(2*PI*m*y / height);
        float s_y = approxSin(2*PI*m*y / height);
        total += (
          noise(cnt, 0, offset) * c_x * c_y +
          noise(cnt, 1, offset) * c_x * s_y +
          noise(cnt, 2, offset) * s_x * c_y +
          noise(cnt, 3, offset) * s_x * s_y
          );
        cnt++;
      }
    } 
    return total / 4;
  }

  // Math Helper
  private float[] a = new float[65536];

  public final float approxSin(float f) {
    return a[(int) (f * 10430.378F) & '\uffff'];
  }

  public final float approxCos(float f) {
    return a[(int) (f * 10430.378F + 16384.0F) & '\uffff'];
  }
}
