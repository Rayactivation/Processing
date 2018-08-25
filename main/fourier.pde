import java.util.Collections;
import java.util.Arrays;

class FourierSeries implements Pattern {
  float[] X_PERIODS = new float[]{0, 0};
  int[] X_RATES = new int[]{int(random(18000, 22000)), int(random(28000, 32000))};
  int[] X_OFFSET = new int[]{int(random(X_RATES[0])), int(random(X_RATES[1]))};
  float[] Y_PERIODS = new float[]{0, 1};
  int[] Y_RATES = new int[]{int(random(18000, 22000)), int(random(28000, 32000))};
  int[] Y_OFFSET = new int[]{int(random(Y_RATES[0])), int(random(Y_RATES[1]))};
  int N = X_PERIODS.length * Y_PERIODS.length;
  float offset = 0;
  int hueOffset = 0;
  Colormap cm;
  String[] allowedColormaps = {
    "Blues", 
    "BrBG", 
    "BuGn", 
    "BuPu", 
    "CMRmap", 
    "GnBu", 
    "Greens", 
    "Greys", 
    "OrRd", 
    "Oranges", 
    "PRGn", 
    "PiYG", 
    "PuBu", 
    "PuBuGn", 
    "PuOr", 
    "PuRd", 
    "Purples", 
    "RdBu", 
    "RdGy", 
    "RdPu", 
    "RdYlBu", 
    "RdYlGn", 
    "Reds", 
    "Spectral", 
    "Wistia", 
    "YlGn", 
    "YlGnBu", 
    "YlOrBr", 
    "YlOrRd", 
    "afmhot", 
    "autumn", 
    "blue", 
    "bone", 
    //"brg", 
    "bwr", 
    "cividis", 
    "cool", 
    "coolwarm", 
    "copper", 
    "cubehelix", 
    //"flag", 
    "gist_earth", 
    "gist_heat", 
    //"gist_ncar", 
    //"gist_rainbow", 
    //"gist_stern", 
    "gnuplot", 
    "gnuplot2", 
    "hot", 
    "inferno", 
    "jet", 
    "magma", 
    //"nipy_spectral", 
    "ocean", 
    "pink", 
    "plasma", 
    //"prism", 
    "seismic", 
    "spring", 
    "summer", 
    "terrain", 
    "viridis", 
    "winter", 
    // These are palattes, not gradients
    //"Set1", 
    //"Set2", 
    //"Set3", 
    //"Accent", 
    //"Dark2", 
    //"Paired", 
    //"Pastel1", 
    //"Pastel2", 
    //"tab10", 
    //"tab20", 
    //"tab20b", 
    //"tab20c", 
  };

  void setup() {
    colorMode(RGB, 255, 255, 255);
    this.cm = randomColormap(allowedColormaps);
    // p
    for (int i = 0; i < 65536; ++i) {
      sineLookup[i] = sin(i * PI * 2.0 / 65536.0);
    }
  }
  void cleanup() {
  };

  void draw() {
    for (int i=0; i<X_PERIODS.length; i++) {
      X_PERIODS[i] = 3 * sin((millis()+X_OFFSET[i]) * 2 * PI / X_RATES[i]);
    }
    for (int i=0; i<Y_PERIODS.length; i++) {
      Y_PERIODS[i] = 3 * sin((millis() +Y_OFFSET[i]) * 2 * PI / Y_RATES[i]);
    }
    float[] a = calcNoise(0, offset);
    float[] b = calcNoise(1, offset);
    float[] c = calcNoise(2, offset);
    float[] d = calcNoise(3, offset);
    Float[] values = new Float[height*width];
    for (int x=0; x<width; x++) {
      for (int y=0; y<height; y++) {
        values[x + y*width] = calculate(x, y, a, b, c, d);
      }
    }
    loadPixels();
    values = normalize(values);
    for (int i=0; i<height*width; i++) {
      pixels[i] = this.cm.getColor(hueOffset + int(255*values[i]));
    }
    updatePixels();
    offset += 2 / frameRate;
    hueOffset += 45 / frameRate;
  }

  float[] calcNoise(int idx, float offset) {
    float[] result = new float[N];
    for (int i=0; i<N; i++) {
      result[i] = noise(i, idx, offset);
    }
    return result;
  }


  float calculate(float x, float y, float[] a, float[]b, float[] c, float[] d) {
    float total = 0;
    int cnt = 0;
    for (float n : X_PERIODS) {
      for (float m : Y_PERIODS) {
        // Having all four sin, cos combinations
        // does actually seem more interesting than
        // just using one.
        float c_x = approxCos(2*PI*n*x / width);
        float s_x = approxSin(2*PI*n*x / width);
        float c_y = approxCos(2*PI*m*y / height);
        float s_y = approxSin(2*PI*m*y / height);
        total += (
          a[cnt] * c_x * c_y +
          b[cnt] * c_x * s_y +
          c[cnt] * s_x * c_y +
          d[cnt] * s_x * s_y);
        cnt++;
      }
    }
    return total;
  }

  // Math Helper
  private float[] sineLookup = new float[65536];

  public final float approxSin(float f) {
    return sineLookup[(int) (f * 10430.378F) & '\uffff'];
  }

  public final float approxCos(float f) {
    return sineLookup[(int) (f * 10430.378F + 16384.0F) & '\uffff'];
  }

  Float[] normalize(Float[] values) {
    List<Float> arr = Arrays.asList(values);
    float mn = Collections.min(arr);
    float mx = Collections.max(arr);
    Float[] result = new Float[values.length];
    for (int i=0; i<values.length; i++) {
      result[i] = norm(values[i], mn, mx);
    }
    return result;
  }
}
