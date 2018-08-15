import com.google.gson.Gson;
import com.google.gson.JsonParser;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import java.io.FileReader;
import java.io.FileNotFoundException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;
import org.javatuples.Pair;

/* Parse the json layout file and create the corresponding OPC clients.
 *
 * The layout file needs to be an array of objects. Each object contains
 * the keys: host, port, point
 * [{host: "127.0.0.1", port: 7890, point: [2, 3, 0], strip: 1}, ...]
 * The order of the points is important and needs to correspond to the ordering
 * of the pixels on each OPC server.
 *
 * If the reciever board expects strips to be of a certain size, set the stripSize
 * variable and nullPixels will be created to fill in any necessary pixels
 */
ArrayList<OPC> setupOpc(String jsonLayoutFile, Integer stripSize) throws IOException {
  ArrayList<OPC> results = new ArrayList<OPC>();
  String layoutJson = readFile(jsonLayoutFile, StandardCharsets.UTF_8);
  JsonArray arr = new JsonParser().parse(layoutJson).getAsJsonArray();

  // Map from OPC -> Strip -> Pixels
  HashMap<Pair<String, Integer>, TreeMap<Integer, ArrayList<PVector>>> pointsByHostPort = new HashMap<Pair<String, Integer>, TreeMap<Integer, ArrayList<PVector>>>();
  float min_x = Float.MAX_VALUE;
  float min_y = Float.MAX_VALUE;
  float max_x = 0;
  float max_y = 0;
  for (int i=0; i<arr.size(); i++) {
    JsonObject o = arr.get(i).getAsJsonObject();
    Pair<String, Integer> hp = new Pair<String, Integer>(o.get("host").getAsString(), o.get("port").getAsInt());

    if (!pointsByHostPort.containsKey(hp)) {
      pointsByHostPort.put(hp, new TreeMap<Integer, ArrayList<PVector>>());
    }
    TreeMap<Integer, ArrayList<PVector>> pointsByStrip = pointsByHostPort.get(hp);
    Integer strip = o.get("strip").getAsInt();
    if (!pointsByStrip.containsKey(strip)) {
      pointsByStrip.put(strip, new ArrayList<PVector>());
    }
    List<PVector> points = pointsByStrip.get(strip);

    JsonArray point = o.get("point").getAsJsonArray();
    PVector pt = new PVector(point.get(0).getAsFloat(), point.get(1).getAsFloat());
    points.add(pt);
    min_x = min(pt.x, min_x);
    min_y = min(pt.y, min_y);
    max_x = max(pt.x, max_x);
    max_y = max(pt.y, max_y);
  }
  float layout_width = max_x - min_x;
  float layout_height = max_y - min_y;
  HashMap<Pair<String, Integer>, OPC> opcByHostPort = new HashMap<Pair<String, Integer>, OPC>();
  for (Pair<String, Integer> hp : pointsByHostPort.keySet()) {
    opcByHostPort.put(hp, new OPC(this, hp.getValue0(), hp.getValue1()));
  }
  for (Map.Entry<Pair<String, Integer>, TreeMap<Integer, ArrayList<PVector>>> item : pointsByHostPort.entrySet()) {
    OPC opc = opcByHostPort.get(item.getKey());
    results.add(opc);
    TreeMap<Integer, ArrayList<PVector>> pointsByStrip = item.getValue();
    int idx = 0;
    for (Integer strip : pointsByStrip.keySet()) {
      ArrayList<PVector> points = pointsByStrip.get(strip);
      for (int i=0; i<points.size(); i++) {
        PVector pt = points.get(i);
        int x = int((pt.x - min_x) * (width - 1) / layout_width);
        int y = int((pt.y - min_y) * (height - 1) / layout_height);
        assert 0 <= x && x < width;
        assert 0 <= y && y < height;
        opc.led(idx, x, y);
        idx++;
      }
      if (stripSize != null) {
        for (int i=points.size(); i<stripSize; i++) {
          opc.nullLed(idx);
          idx++;
        }
      }
    }
  }
  return results;
}

static String readFile(String path, Charset encoding)
  throws IOException
{
  byte[] encoded = Files.readAllBytes(Paths.get(path));
  return new String(encoded, encoding);
}
