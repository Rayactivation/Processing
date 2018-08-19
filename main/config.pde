
void configure() {
  HashMap<String, String> map = loadConfig("config.txt");
  randomPattern = boolean(map.get("randomPattern").toLowerCase());
  layoutFile = map.get("layoutFile");
  Integer rawStripSize = int(map.get("stripSize"));
  stripSize = rawStripSize <=0 ? null : rawStripSize;
  patternSwitchTime = int(map.get("patternSwitchTime")) * 1000;
  showLocations = boolean(map.get("showLocations").toLowerCase());
  doBlur = boolean(map.get("doBlur").toLowerCase());;
}

HashMap<String, String> loadConfig(String filename) {
  String[] lines = loadStrings(filename);
  HashMap<String, String> map = new HashMap<String, String>();
  for (String line : lines) {
    if (line.charAt(0) == '#') {
      continue;
    }
    String[] kv = split(line, ":");
    String key = trim(kv[0]);
    String value = trim(kv[1]);
    map.put(key, value);
  }
  return map;
}
