//set up the OPC layout for the Ray
OPC opc1;
OPC opc2;
OPC opc3;
OPC opc4;

void opcSetup() {
  // Left front wing
  opc1 = new OPC(this, "10.0.0.30", 7890);
  // Left back wing and body back
  opc2 = new OPC(this, "10.0.0.31", 7890);
  // Right front wing
  opc3 = new OPC(this, "10.0.0.32", 7890);
  // Right back wing and body front
  opc4 = new OPC(this, "10.0.0.33", 7890); 

  //Read from layout file and set pixels for each opc object
  
  
  
}
