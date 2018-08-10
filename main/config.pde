void configure() {
  HashMap<String, String> map = loadConfig("config.txt");
  randomPattern = map.get("randomPattern").toLowerCase() == "true";
  debug = map.get("debug").toLowerCase() == "true";
  layoutFile = map.get("layoutFile");
  Integer rawStripSize = int(map.get("stripSize"));
  stripSize = rawStripSize <=0 ? null : rawStripSize;
  patternSwitchTime = int(map.get("patternSwitchTime")) * 1000;
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
    println(key + "  " + value);
    map.put(key, value);
  } 
  return map;
}
