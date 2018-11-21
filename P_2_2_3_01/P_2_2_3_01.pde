// P_2_2_3_01.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
//
// http://www.generative-gestaltung.de
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/**
 * form mophing process by connected random agents
 * 
 * MOUSE
 * click               : start a new circe
 * position x/y        : direction of floating
 * 
 * KEYS
 * 1-2                 : fill styles
 * f                   : freeze. loop on/off
 * Delete/Backspace    : clear display
 * s                   : save png
 * r                   : start pdf recording
 * e                   : stop pdf recording
 */
import oscP5.*;
import processing.pdf.*;
import java.util.Calendar;



import processing.sound.*;
SoundFile file;

boolean recordPDF = false;

int formResolution = 15;
int stepSize = 2;
float distortionFactor = 1;
float initRadius = 150;
float centerX, centerY;
float[] x = new float[formResolution];
float[] y = new float[formResolution];

boolean filled = false;
boolean freeze = false;

OscP5 oscP5;
float mouthVal, prevMouthVal;
float pos;


void setup() {
  size(640, 480);
  smooth();
  file = new SoundFile(this, "bubble.wav");

  // init form
  centerX = width/2; 
  centerY = height/2;
  float angle = radians(360/float(formResolution));
  for (int i=0; i<formResolution; i++) {
    x[i] = cos(angle*i) * initRadius;
    y[i] = sin(angle*i) * initRadius;
  }

  stroke(0, 50);
  background(255);
  oscP5 = new OscP5(this, 12000);
  prevMouthVal = 0.0;
}


void draw() {
  if (prevMouthVal<1.9 && mouthVal>2.1) {
    mouthOpen();
  }
  // floating towards mouse position
  if (mouseX != 0 || mouseY != 0) {
    centerX += (mouseX-centerX) * 0.01;
    centerY += (mouseY-centerY) * 0.01;
  }

  // calculate new points
  for (int i=0; i<formResolution; i++) {
    x[i] += random(-stepSize, stepSize);
    y[i] += random(-stepSize, stepSize);
    // ellipse(x[i], y[i], 5, 5);
  }

  strokeWeight(0.75);
  stroke(pos*40);
  if (filled) fill(random(255));
  else noFill();

  beginShape();
  // start controlpoint
  curveVertex(x[formResolution-1]+centerX, y[formResolution-1]+centerY);

  // only these points are drawn
  for (int i=0; i<formResolution; i++) {
    curveVertex(x[i]+centerX, y[i]+centerY);
  }
  curveVertex(x[0]+centerX, y[0]+centerY);

  // end controlpoint
  curveVertex(x[1]+centerX, y[1]+centerY);
  endShape();
  prevMouthVal = mouthVal;
}


// events
//void mousePressed() {
//  //init form on mouse position
//  centerX = mouseX; 
//  centerY = mouseY;
//  float angle = radians(360/float(formResolution));
//  float radius = initRadius * random(0.5, 1.0);
//  for (int i=0; i<formResolution; i++) {
//    x[i] = cos(angle*i) * radius;
//    y[i] = sin(angle*i) * radius;
//  }
//}

void mouthOpen() {
  centerX = random(0, width);
  centerY = random(0, height);
  float angle = radians(360/float(formResolution));
  float radius = initRadius * random(0.5, 1.0);
  for (int i=0; i<formResolution; i++) {
    x[i] = cos(angle*i) * radius;
    y[i] = sin(angle*i) * radius;
  }
  file.play();
}


void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == DELETE || key == BACKSPACE) background(255);

  if (key == '1') filled = false;
  if (key == '2') filled = true;

  // ------ pdf export ------
  // press 'r' to start pdf recording and 'e' to stop it
  // ONLY by pressing 'e' the pdf is saved to disk!
  if (key =='r' || key =='R') {
    if (recordPDF == false) {
      beginRecord(PDF, timestamp()+".pdf");
      println("recording started");
      recordPDF = true;
      stroke(0, 50);
    }
  } else if (key == 'e' || key =='E') {
    if (recordPDF) {
      println("recording stopped");
      endRecord();
      recordPDF = false;
      background(255);
    }
  } 

  // switch draw loop on/off
  if (key == 'f' || key == 'F') freeze = !freeze;
  if (freeze == true) noLoop();
  else loop();
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {

  if (theOscMessage.checkAddrPattern("/wek/outputs") == true) {
    if (theOscMessage.checkTypetag("f")) {
      float f = theOscMessage.get(0).floatValue();
      pos = f;
    }
  }
  //if (theOscMessage.checkAddrPattern("/gesture/mouth/height")==true) {
  //  /* print the address pattern and the typetag of the received OscMessage */
  //  print("### received an osc message.");
  //  print(" addrpattern: "+theOscMessage.addrPattern());
  //  print(" message: "+theOscMessage.get(0).floatValue());
  //  println(" typetag: "+theOscMessage.typetag());
  //  mouthVal = theOscMessage.get(0).floatValue();
  //}
}