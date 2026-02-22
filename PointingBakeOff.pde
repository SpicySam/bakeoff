import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;

//when in doubt, consult the Processsing reference: https://processing.org/reference/

int margin = 200; //set the margin around the squares
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 40; // padding between buttons and also their width/height
ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
int trialNum = 0; //the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks
Robot robot; //initialized in setup 

int numRepeats = 1; //sets the number of times each button repeats in the test

// Flash timing: toggle every N frames (at 60fps, 6 frames = ~100ms = very fast flash)
final int FLASH_INTERVAL = 6; // frames between flash toggles — lower = faster flash

void setup()
{
  size(700, 700);
  noCursor(); // hide system cursor — we draw our own precise crosshair
  noStroke();
  textFont(createFont("Arial", 16));
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER);

  try {
    robot = new Robot();
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }

  //===DON'T MODIFY MY RANDOM ORDERING CODE==
  for (int i = 0; i < 16; i++)
    for (int k = 0; k < numRepeats; k++)
      trials.add(i);

  Collections.shuffle(trials);
  System.out.println("trial order: " + trials);
  
  surface.setLocation(0, 0);
}


void draw()
{
  background(0);

  if (trialNum >= trials.size()) // test is over
  {
    float timeTaken = (finishTime - startTime) / 1000f;
    float penalty = constrain(((95f - ((float)hits * 100f / (float)(hits + misses))) * .2f), 0, 100);
    fill(255);
    text("Finished!", width / 2, height / 2); 
    text("Hits: " + hits, width / 2, height / 2 + 20);
    text("Misses: " + misses, width / 2, height / 2 + 40);
    text("Accuracy: " + (float)hits * 100f / (float)(hits + misses) + "%", width / 2, height / 2 + 60);
    text("Total time taken: " + timeTaken + " sec", width / 2, height / 2 + 80);
    text("Average time for each button: " + nf((timeTaken) / (float)(hits + misses), 0, 3) + " sec", width / 2, height / 2 + 100);
    text("Average time for each button + penalty: " + nf(((timeTaken) / (float)(hits + misses) + penalty), 0, 3) + " sec", width / 2, height / 2 + 140);
    return;
  }

  fill(255);
  text((trialNum + 1) + " of " + trials.size(), 40, 20);

  for (int i = 0; i < 16; i++)
    drawButton(i);

  // Draw a small, precise crosshair cursor instead of a big circle
  drawCrosshair(mouseX, mouseY);
}

void drawCrosshair(int cx, int cy)
{
  stroke(255, 0, 0);
  strokeWeight(1.5);
  int arm = 10; // length of each crosshair arm
  int gap = 3;  // gap around center for clarity
  // horizontal arms
  line(cx - arm, cy, cx - gap, cy);
  line(cx + gap, cy, cx + arm, cy);
  // vertical arms
  line(cx, cy - arm, cx, cy - gap);
  line(cx, cy + gap, cx, cy + arm);
  // tiny center dot
  fill(255, 0, 0);
  noStroke();
  ellipse(cx, cy, 2, 2);
  noStroke(); // reset
}

void mousePressed()
{
  if (trialNum >= trials.size())
    return;

  if (trialNum == 0)
    startTime = millis();

  if (trialNum == trials.size() - 1)
  {
    finishTime = millis();
    println("we're done!");
  }

  Rectangle bounds = getButtonLocation(trials.get(trialNum));

  if ((mouseX > bounds.x && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y && mouseY < bounds.y + bounds.height))
  {
    System.out.println("HIT! " + trialNum + " " + (millis() - startTime));
    hits++; 
  } 
  else
  {
    System.out.println("MISSED! " + trialNum + " " + (millis() - startTime));
    misses++;
  }

  trialNum++;
}  

Rectangle getButtonLocation(int i)
{
   int x = (i % 4) * (padding + buttonSize) + margin;
   int y = (i / 4) * (padding + buttonSize) + margin;
   return new Rectangle(x, y, buttonSize, buttonSize);
}

void drawButton(int i)
{
  Rectangle bounds = getButtonLocation(i);

  if (trials.get(trialNum) == i) // this is the TARGET button
  {
    // Flash between bright white and black based on frameCount
    boolean flashOn = (frameCount / FLASH_INTERVAL) % 2 == 0;
    if (flashOn)
      fill(255); // bright white
    else
      fill(0, 0, 0); // black (invisible against background — very striking flash)
    
    // Draw a colored outline so the button position is always visible even when black
    stroke(0, 255, 0); // green outline always shows the boundary
    strokeWeight(2);
    rect(bounds.x, bounds.y, bounds.width, bounds.height);
    noStroke();
  }
  else
  {
    fill(200); // non-target: gray
    rect(bounds.x, bounds.y, bounds.width, bounds.height);
  }
}

void mouseMoved() {}
void mouseDragged() {}
void keyPressed() {}
