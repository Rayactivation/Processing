OPC opc1;
OPC opc2;
OPC opc3;
OPC opc4;

int rayCanvasWidth = 500;
int rayCanvasHeight = 250;

import java.util.Iterator;

final float MAX_SPEED = 4;
final float BOUNCE = -0.5;
final float LIFESPAN_DECREMENT = 2.0;
final int SHRINK_RATE = 2;//5;
final int MAX_PARTICLES = 100;

Spawner spawner;
boolean displayColour = true;
int delay = 0;

ParticleSystem system = new ParticleSystem();

void setup() {
  size(800, 300);
  background(0);

  rect(width/2 - rayCanvasWidth / 2, height / 2 - rayCanvasHeight / 2, rayCanvasWidth, rayCanvasHeight);

  opc1 = new OPC(this, "10.0.0.30", 7890);
  opc2 = new OPC(this, "10.0.0.31", 7890);
  opc3 = new OPC(this, "10.0.0.32", 7890);
  opc4 = new OPC(this, "10.0.0.33", 7890);

  int vertSpacing = 15;
  int vertOffSet = 100;

  opc1.ledStrip(0, 32, width/2, 0 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc1.ledStrip(1, 32, width/2, 1 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc2.ledStrip(0, 32, width/2, 2 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc2.ledStrip(1, 32, width/2, 3 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc3.ledStrip(0, 32, width/2, 4 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc3.ledStrip(1, 32, width/2, 5 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc4.ledStrip(0, 32, width/2, 6 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);
  opc4.ledStrip(1, 32, width/2, 7 * height/vertSpacing + vertOffSet, width / 70.0, 0, false);

spawner = new Spawner();
}


void draw() {
  background(0);
  rect(width/2 - rayCanvasWidth / 2, height / 2 - rayCanvasHeight / 2, rayCanvasWidth, rayCanvasHeight);

  println(mouseX, mouseY);
    // Update our particle system each frame
  system.update();
  spawner.update();
  
  if (system.count < MAX_PARTICLES) {
    if (millis() > delay) {
      system.addParticle(new PVector(spawner.loc.x, spawner.loc.y));
      delay = millis() + 5;
    }
  }
  
  noStroke();
  fill(255, 50);
  rect(0, 0, width, height);
}


void mouseDragged()
{
  if (system.count < MAX_PARTICLES) {
    system.addParticle(new PVector(mouseX, mouseY));
  }
}

void keyPressed() 
{
  displayColour = !displayColour;  
}

class ParticleSystem
{
  ArrayList<Wanderer> wanderers = new ArrayList<Wanderer>();
  int count = 0;
  
  ParticleSystem() { }
  
  void addParticle(PVector loc)
  {
    count++;
    wanderers.add(new Wanderer(loc));
  }
  
  void update()
  {
    // Use an iterator to loop through active particles
    Iterator<Wanderer> i = wanderers.iterator();
    
    while(i.hasNext()) {
      // Get next particle
      Wanderer w = i.next();
      
      // update position and lifespan
      w.update();
      
      // Remove particle if dead
      if (w.isDead()) {
        i.remove();
        count--;
      } else {
        w.display();
      }
    }
  }
}

class Particle
{
  PVector velocity = new PVector(random(-MAX_SPEED, MAX_SPEED), random(-MAX_SPEED, MAX_SPEED));
  PVector pos;
  int size = 250;
  ColourGenerator colour = new ColourGenerator();
  
  Particle(PVector origin)
  {
    pos = origin;  
  }
  
  void move()
  {
    // Apply velocity to particle
    pos.add(velocity);
    
    // Boundary check
    if (pos.x < 0) {
      pos.x = 0;
      velocity.x *= BOUNCE;
    } else if (pos.x > width) {
      pos.x = width;
      velocity.x *= BOUNCE;
    }
    if (pos.y < 0) {
      pos.y = 0;
      velocity.y *= BOUNCE;
    } else if (pos.y > height) {
      pos.y = height;
      velocity.y *= BOUNCE;
    }
    
    //colour.update();
    
    // Decrease size
    size -= SHRINK_RATE;
  }
  
  void display()
  {
    colour.update();
    noFill();
    fill(colour.R, colour.G, colour.B);
    ellipse(pos.x, pos.y, size, size);
  }
  
  boolean isDead()
  {
    if (size < 0) {
      return true;
    } else {
      return false;
    }
  }
}

class Wanderer {
  PVector loc;
  PVector vel;
  PVector acc;
  
  int size = 100;
  float angle;

  ColourGenerator colour = new ColourGenerator();
  
  Wanderer(PVector loc2) 
  {
    loc = new PVector(loc2.x, loc2.y);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
  }
  
  void update()
  {
    // Move in random direction with random speed
    angle += random(0, TWO_PI);
    float magnitude = random(0, 4); //3
    
    // Work out force 
    acc.x += cos(angle) * magnitude;
    acc.y += sin(angle) * magnitude;
    
    // limit result
    acc.limit(3);
    
    // Add to current velocity
    vel.add(acc);
    vel.limit(6);
    
    // Appy result to current location
    loc.add(vel);
    
    // Wrap around screen
    if (loc.x > width)
      loc.x -= width;
     if (loc.x < 0)
       loc.x += width;
     if(loc.y > height)
       loc.y -= height;
     if(loc.y < 0)
       loc.y += height;
       
       size -= SHRINK_RATE;
  }
  
  void display() 
  {
     if (displayColour) {
         colour.update();
        fill(colour.R, colour.G, colour.B);
     } else {
         fill(255);
     }
     ellipse(loc.x, loc.y, size, size);
  }
  
  boolean isDead()
  {
    if (size < 0) {
      return true;
    } else {
      return false;
    }
  }
}

class Spawner {
  PVector loc;
  PVector target;
  int interval;
  
  Spawner() 
  {
    loc = new PVector(width/2, height/2);
    target = new PVector(random(width), random(height));
    interval = millis() + (int) random(750, 1500);
  }
  
  void update()
  {
     if (millis() > interval) {
       interval = millis() + (int) random(750, 1500);
       target = new PVector(random(width), random(height));
     }
     
     loc.x = lerp(loc.x, target.x, 0.025);
     loc.y = lerp(loc.y, target.y, 0.025);
  }
  
}

class ColourGenerator
{
  final static float MIN_SPEED = 0.2;
  final static float MAX_SPEED = 0.7;
  float R, G, B;
  float Rspeed, Gspeed, Bspeed;
  
  ColourGenerator()
  {
    init();  
  }
  
  public void init()
  {
    // Starting colour
    R = random(255);
    G = random(255);
    B = random(255);
    
    // Starting transition speed
    Rspeed = (random(1) > 0.5 ? 1 : -1) * random(MIN_SPEED, MAX_SPEED);
    Gspeed = (random(1) > 0.5 ? 1 : -1) * random(MIN_SPEED, MAX_SPEED);
    Bspeed = (random(1) > 0.5 ? 1 : -1) * random(MIN_SPEED, MAX_SPEED);
  }
  
  public void update()
  {
    // Use transition to alter original colour (Keep within RGB bounds)
    Rspeed = ((R += Rspeed) > 255 || (R < 0)) ? -Rspeed : Rspeed;
    Gspeed = ((G += Gspeed) > 255 || (G < 0)) ? -Gspeed : Gspeed;
    Rspeed = ((B += Bspeed) > 255 || (B < 0)) ? -Bspeed : Bspeed;
  }
  
}
